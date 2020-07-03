//
//  AccessPointViewController.swift
//  cir_wireless
//
//  Created by softel on 24/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import UIKit
import CoreBluetooth
import SystemConfiguration.CaptiveNetwork

class AccessPointViewController: UIViewController {
    
    let REPEAT_CYCLE_TIME                       = 15
    let TIMEOUT                                 = 30
    let _ACCEPT                                 = NSLocalizedString("Accept", comment: "")
    
    
    let MAX_LENGTH_SSID_CHARACTERS              = 40
    let MAX_LENGTH_PASSCODE_CHARACTERS          = 20

    
    var isWiFiAvailable                         : Bool = false
    
    
    var wiFiName                                : String?
    var wiFiPasscode                            : String?
    
    
    // Variable para controlar el flujo de la configuracion de WiFi
    var machineState                            : AccessPointsMachineState = ._POLING
    var configurationState                      : ConfigurationState?
    
    
    var cirWireless                             : CirWirelessModel?
    var bluetoothActions                        : CoreBluetoothActions?
     
     
    // MARK: Servicios bluetooth de la cir wireless
    var cwProtocolService                       : CBService?
     
     
    // MARK: Caracteristicas bluetooth de la cir wireless
    var cwProtocolNotificationCharac            : CBCharacteristic?
    var cwProtocolWriteCharacteristic           : CBCharacteristic?
    
    
    var configuringWiFiAlert                    : UIAlertController!
    var validateWiFiConnection                  : UIAlertController!
    
    
    var timer                                   : Timer?
    var initialTime                             : Double?
    var currentTime                             : Double?
    
    
    // Outlets
    @IBOutlet weak var passcodeField: UITextField!
    @IBOutlet weak var cirWirelessMac: UILabel!
    @IBOutlet weak var ssid: UILabel!
    
    
    // Ciclo de vida de la vista --------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadViews()
        
        if let _ = cirWireless {
            cirWirelessMac.text = cirWireless?.getCirWirelessMac()
        }
        
        
        if let wiFiName = getWiFiSsid(), let _ = cwProtocolNotificationCharac, let _ = cwProtocolWriteCharacteristic {
            self.wiFiName   = wiFiName
            ssid.text       = wiFiName
            startTimer()
            isWiFiAvailable = true
            bluetoothActions!.bluetoothPolingDelegate = self
            bluetoothActions!.setCirWirelessNotifyCharacteristic(enable: true, notifyCharacteristic: cwProtocolNotificationCharac!)
            machineState    = ._GETTING_AP
        }
        

        passcodeField.delegate = self
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if wiFiName == nil {
            popUpWiFiUnavailable()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear:")
        // Se desactiva la notificacion
        bluetoothActions?.setCirWirelessNotifyCharacteristic(enable: false, notifyCharacteristic: cwProtocolNotificationCharac!)
        stopTimerTest()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        print("Implements did dissapear if needed")
    }
    // ---------------------------------------------------------------------
    
    
    private func loadViews () {
        popUpConfiguring()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    // Obtenemos el nombre del WiFi al que esta conectado el iPhone ----------------
    func getWiFiSsid () -> String? {
        var ssid: String?
        
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        
        return ssid
    }
    // ----------------------------------------------------------------------------
    
    
    // Outlets Actions -------------------------------------------------------------
    @IBAction func acceptPasscode(_ sender: Any) {
        
        if isWiFiAvailable {
            let passcodeFieldText = passcodeField.text ?? ""
            if !(passcodeFieldText.isEmpty) {
                
                print(passcodeFieldText.count)
                print(wiFiName!.count)
                if (passcodeFieldText.count <= MAX_LENGTH_PASSCODE_CHARACTERS && wiFiName!.count <= MAX_LENGTH_SSID_CHARACTERS) {
                    
                    initialTime     = NSDate().timeIntervalSince1970
                    wiFiPasscode    = passcodeFieldText
                    machineState    = ._INIT_CONFIG_PROCESS
                                        
                    self.present(configuringWiFiAlert, animated: true, completion: nil)
                    
                } else {
                    
                    popUpLargePasscodeOrSsid()
                }
                
            } else {
                
                popUpBadPassword()
            }
            
        } else {
            
            popUpWiFiUnavailable()
            
        }
    }
    // ----------------------------------------------------------------------------
    
    
    // Timer para revisar el proceso de configuration -----------------------------
    func startTimer () {
      guard timer == nil else { return }

      timer =  Timer.scheduledTimer(
          timeInterval: TimeInterval(REPEAT_CYCLE_TIME),
          target      : self,
          selector    : #selector(checkTimeout),
          userInfo    : nil,
          repeats     : true)
    }
    
    
    func stopTimerTest() {
      timer?.invalidate()
      timer = nil
    }
    
    
    @objc func checkTimeout () {
        currentTime = NSDate().timeIntervalSince1970
        let difference = Int(abs(currentTime! - initialTime!))
        
        if difference > TIMEOUT {
            stopTimerTest()
            
            configuringWiFiAlert.dismiss(animated: true, completion: {
                self.popUpTimeout()
                self.machineState        = ._POLING
                self.configurationState  = ._DEFAULT
            })
            
            return
        }
        
        print("**********************OK TIMEOUT**********************")
    }
    // ----------------------------------------------------------------------------
    
    
    // Funciones para mover el teclado al escribir en los text field --------------
    @objc func keyboardWillShow(sender: NSNotification) {
         self.view.frame.origin.y = -150 // Move view 150 points upward
    }

    
    @objc func keyboardWillHide(sender: NSNotification) {
         self.view.frame.origin.y = 0 // Move view to original position
    }
    // -----------------------------------------------------------------------------
    
    
    private func wiFiConfigurationProcess (protocolResponse: CirProtocolResponse) {
        
        switch machineState {
            
        case ._POLING :
            print("Poling")
                         
            
        case ._GETTING_AP :
            print("_GETTING_AP")
            
            if protocolResponse.isAPoleoPackage() {
                
                let command = CirWirelessCommands.getSeenAccessPointsCommand()
                print("command access points: \(command.description)")
                bluetoothActions?.writeCirWirelessCharacteristic(command: command, characteristic: cwProtocolWriteCharacteristic!, type: .withoutResponse)
                    
            } else if protocolResponse.response == CirProtocolResponses._SEEN_ACCESS_POINTS.rawValue {
                print("macs found")
                    
                if let _ = protocolResponse.getPayload() {
                        
                    machineState = ._POLING

                } else {
                        
                    isWiFiAvailable = false
                    popUpCirNotSeeingAP()
                        
                }
        }
    
        case ._INIT_CONFIG_PROCESS:
            print("Initializing")
            
            if protocolResponse.isAPoleoPackage() {
                
                print("Writing")
                let command = CirWirelessCommands.setCirInSlaveMode(cirWirelessMac: (cirWireless?.getCirWirelessMacBytes())!, mode: ._MASTER_SLAVE)
                bluetoothActions?.writeCirWirelessCharacteristic(command: command, characteristic: cwProtocolWriteCharacteristic!, type: .withoutResponse)
                
            } else if protocolResponse.response == ATResponses._AT_OK_COMMAND.rawValue {
                
                machineState = ._CONFIGURING
                configurationState  = ._SLAVE_MASTER_DONE
                
            }
            
        case ._CONFIGURING :
            
             // print("protocolResponse: \(String(format: "%02x", protocolResponse.response))")
            
            if protocolResponse.response == ATResponses._AT_COMMAND_READY.rawValue {
                print("AT COMMAND IS READY")
                validateConfigurationState(response: protocolResponse)
            } else {
                let command = CirWirelessCommands.readATStatus()
                bluetoothActions?.writeCirWirelessCharacteristic(command: command, characteristic: cwProtocolWriteCharacteristic!, type: .withoutResponse)
            }
            
        default:
            break
        }
    }
    
    
    private func validateConfigurationState (response: CirProtocolResponse) {
        
        if let str = NSString(data: uInt8ToData(uintArray: response.decryptPayload(cirWirelessMac: (cirWireless?.getCirWirelessMacBytes())!)),
                              encoding: String.Encoding.utf8.rawValue) as String? {
            if str.contains(ATResponsesString._AT_OK.rawValue) {
                
                initialTime = NSDate().timeIntervalSince1970 // Actualizamos el tiempo para ver el timeout
                
                switch configurationState {
                    
                case ._SLAVE_MASTER_DONE:
                    print("***************************SLAVE_MASTER_DONE***************************")
                    let command = CirWirelessCommands.resetWiFiTask(cirWirelessMac: (cirWireless?.getCirWirelessMacBytes())!)
                    bluetoothActions?.writeCirWirelessCharacteristic(command: command, characteristic: cwProtocolWriteCharacteristic!, type: .withoutResponse)
                    configurationState = ._RESET_WIFI
                    
                case ._RESET_WIFI :
                    print("***************************_RESET_WIFI***************************")
                    let command = CirWirelessCommands.setAPName(cirWirelessMac: (cirWireless?.getCirWirelessMacBytes())!, ssid: wiFiName!,
                                                                passcode: wiFiPasscode!, flag: ATModes._NOT_SEND_SSID.rawValue)
                    
                    bluetoothActions?.writeCirWirelessCharacteristic(command: command, characteristic: cwProtocolWriteCharacteristic!, type: .withoutResponse)
                    configurationState = ._SET_INTERNAL_WIFI
                    
                case ._SET_INTERNAL_WIFI:
                    print("***************************_SET_INTERNAL_WIFI***************************")
                    let command = CirWirelessCommands.setAutoConnect(cirWirelessMac: (cirWireless?.getCirWirelessMacBytes())!, enable: 1)
                    bluetoothActions?.writeCirWirelessCharacteristic(command: command, characteristic: cwProtocolWriteCharacteristic!, type: .withoutResponse)
                    configurationState = ._SET_AUTOCONNECTION
                    
                case ._SET_AUTOCONNECTION:
                    print("***************************_SET_AUTOCONNECTION***************************")
                    let command = CirWirelessCommands.setWiFiConfiguration(cirWirelessMac: (cirWireless?.getCirWirelessMacBytes())!,
                                                                           ssid: wiFiName!, passcode: wiFiPasscode!)
                    
                    bluetoothActions?.writeCirWirelessCharacteristic(command: command, characteristic: cwProtocolWriteCharacteristic!, type: .withoutResponse)
                    
                    configurationState = ._SEND_CONFIGURATION
                    
                case ._SEND_CONFIGURATION:
                    print("***************************_SEND_CONFIGURATION***************************")

                    stopTimerTest()
                    machineState = ._POLING
                    configurationState = ._DEFAULT

                    configuringWiFiAlert.dismiss(animated: true, completion: {
                        self.popUpConfigurationSuccessfullyDone()
                        self.passcodeField.text = ""
                    })

                default:
                    break
                }
                
            } else {
                
                machineState = ._POLING
                configuringWiFiAlert.dismiss(animated: true, completion: {
                    self.popUpErrorWhileConfigWiFi()
                })
                
            }
        }
    }
    
    
    // Pop up Area :D --------------------------------------------------------------
    private func popUpBadPassword () {
        var badPasscodeAlert        : UIAlertController!
        
        let badPasscodeTitle        = NSLocalizedString("Bad Passcode Title", comment: "Passcode empty")
        let badPasscodeMessage      = NSLocalizedString("Bad Passcode Message", comment: "Message")
        
        let badPasscodeComponents   = AlertComponents(alertTitle: badPasscodeTitle, alertMessage: badPasscodeMessage)
        let badPasscodeActions      = AlertActionComponents(buttonTitle: _ACCEPT, buttonHandler: {_ in
            badPasscodeAlert.dismiss(animated: true, completion: nil)
        })
        
        badPasscodeAlert            = PopUpAlert.popUpOneButton(alertCharacteristic: badPasscodeComponents, buttonCharacteristic: badPasscodeActions)
        
        self.present(badPasscodeAlert, animated: true, completion: nil)
    }
    
    
    private func popUpLargePasscodeOrSsid () {
        var largeFieldPopUp         : UIAlertController!
        
        let title                   = NSLocalizedString("Characters Exceeded Title", comment: "Characters exceeded")
        let message                 = NSLocalizedString("Characters Exceeded Message", comment: "")
        
        let largeAlertComponents    = AlertComponents(alertTitle: title, alertMessage: message)
        let largeAlertActions       = AlertActionComponents(buttonTitle: _ACCEPT, buttonHandler: {_ in
            largeFieldPopUp.dismiss(animated: true, completion: nil)
        })
        
        largeFieldPopUp             = PopUpAlert.popUpOneButton(alertCharacteristic: largeAlertComponents, buttonCharacteristic: largeAlertActions)
        
        self.present(largeFieldPopUp, animated: true, completion: nil)
    }
    
    
    private func popUpConfiguring () {
        
        let configTitle             = NSLocalizedString("Sending Passcode Title", comment: "Sending configuration to CIR")
        let configMessage           = NSLocalizedString("Please Wait", comment: "Wait")
        
        let configComponents        = AlertComponents(alertTitle: configTitle, alertMessage: configMessage)
        
        configuringWiFiAlert        = PopUpAlert.popUp(alertCharacteristic: configComponents)
    }
    
    
    private func popUpWiFiUnavailable () {
        var wiFiAlert               : UIAlertController!
        
        let wiFiUnavailableTitle        = NSLocalizedString("WiFi Unavailable", comment: "WiFi is turned off or disconnected")
        let wiFiUnavailableMessage      = NSLocalizedString("WiFi Unavailable Message", comment: "Message")
        
        let wiFiUnavailableComponents   = AlertComponents(alertTitle: wiFiUnavailableTitle, alertMessage: wiFiUnavailableMessage)
        let wiFiUnavailableActions      = AlertActionComponents(buttonTitle: _ACCEPT, buttonHandler: {_ in
            wiFiAlert.dismiss(animated: true, completion: nil)
        })
        
        wiFiAlert                       = PopUpAlert.popUpOneButton(alertCharacteristic: wiFiUnavailableComponents, buttonCharacteristic: wiFiUnavailableActions)
        
        self.present(wiFiAlert, animated: true, completion: nil)
    }
    
    
    private func popUpCirNotSeeingAP () {
        var wiFiAlert               : UIAlertController!
        
        let wiFiNotSeenTitle        = NSLocalizedString("CIR Not Seen AP", comment: "CIR Wireless cannot see WiFi Networks")
        let wiFiNotSeenMessage      = NSLocalizedString("CIR Not Seen AP Message", comment: "")
        
        let wiFiUnavailableComponents   = AlertComponents(alertTitle: wiFiNotSeenTitle, alertMessage: wiFiNotSeenMessage)
        let wiFiUnavailableActions      = AlertActionComponents(buttonTitle: _ACCEPT, buttonHandler: {_ in
            wiFiAlert.dismiss(animated: true, completion: nil)
        })
        
        wiFiAlert                       = PopUpAlert.popUpOneButton(alertCharacteristic: wiFiUnavailableComponents, buttonCharacteristic: wiFiUnavailableActions)
        
        self.present(wiFiAlert, animated: true, completion: nil)
    }
    
    
    private func popUpErrorWhileConfigWiFi () {
        var wiFiAlert               : UIAlertController!
        
        let errorOcurredTitle       = NSLocalizedString("Error While Configuring", comment: "SSID or Passcode is not correct")
        let errorOcurredMessage     = NSLocalizedString("Error While Configuring Message", comment: "")
        
        let errorComponents         = AlertComponents(alertTitle: errorOcurredTitle, alertMessage: errorOcurredMessage)
        let errorActions            = AlertActionComponents(buttonTitle: _ACCEPT, buttonHandler: {_ in
            wiFiAlert.dismiss(animated: true, completion: nil)
        })
        
        wiFiAlert                   = PopUpAlert.popUpOneButton(alertCharacteristic: errorComponents, buttonCharacteristic: errorActions)
        
        self.present(wiFiAlert, animated: true, completion: nil)
        
    }
    
    
    private func popUpConfigurationSuccessfullyDone () {
        var successAlert        : UIAlertController!
        
        let successTitle        = NSLocalizedString("Configuration Completed", comment: "")
        let successMessage      = NSLocalizedString("Configuration Completed Message", comment: "")
        
        let successComponents    = AlertComponents(alertTitle: successTitle, alertMessage: successMessage)
        let successActions       = AlertActionComponents(buttonTitle: _ACCEPT, buttonHandler: { _ in
            successAlert.dismiss(animated: true, completion: nil)
        })
        
        successAlert            = PopUpAlert.popUpOneButton(alertCharacteristic: successComponents, buttonCharacteristic: successActions)
        
        self.present(successAlert, animated: true, completion: nil)
    }
    
    private func popUpTimeout () {
        var timeoutAlert          : UIAlertController!
           
        let timeoutTitle          = NSLocalizedString("Timeout Exceeded", comment: "Timeout exceeded")
        let timeoutMessage        = NSLocalizedString("Timeout Exceeded Message", comment: "")
           
        let timeoutComponents     = AlertComponents(alertTitle: timeoutTitle, alertMessage: timeoutMessage)
        let timeoutActions        = AlertActionComponents(buttonTitle: _ACCEPT, buttonHandler: {_ in
            timeoutAlert.dismiss(animated: true, completion: nil)
        })
           
        timeoutAlert           = PopUpAlert.popUpOneButton(alertCharacteristic: timeoutComponents, buttonCharacteristic: timeoutActions)
           
        self.present(timeoutAlert, animated: true, completion: nil)
    }
    // -----------------------------------------------------------------------------
    
}


extension AccessPointViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}


extension AccessPointViewController: BluetoothPolingProtocol {
    
    func successfullyReadCharacteristic(characteristic: CBCharacteristic, readValue: Data?) {
        let characteristicUuidString = characteristic.uuid.uuidString
        
        if characteristicUuidString == cwProtocolNotificationCharac?.uuid.uuidString, let response = readValue {
            print("response: \(response.hexDescription)")
            let protocolResponse = CirProtocolResponse(protocolResponse: response.hexDescription.hexaToBytes)
            wiFiConfigurationProcess(protocolResponse: protocolResponse)
        }
        
    }
    
    func successfullyWrittenInCharacteristic(characteristic: CBCharacteristic, writtenValue: Data) {
        print("successfullyWrittenInCharacteristic: \(writtenValue.hexDescription) \(writtenValue)")
    }
    
    func successfullyWrittenInDescriptor(descriptor: CBDescriptor, writtenValue: Data) {
        print("Written in descriptor")
    }
    
}


enum AccessPointsMachineState {
    
    case _INIT_CONFIG_PROCESS
    
    case _CONFIGURING

    case _GETTING_AP
    
    case _SET_SSID
    
    case _SET_PASSCODE
    
    case _POLING

}


enum ConfigurationState {
    
    case _SLAVE_MASTER_DONE
    
    case _RESET_WIFI
    
    case _SET_INTERNAL_WIFI
    
    case _SET_AUTOCONNECTION
    
    case _SEND_CONFIGURATION
    
    case _DEFAULT
    
}



/*
 case ._SET_SSID :
     print("._SET_SSID")
     if protocolResponse.isAPoleoPackage() {
         
         let wiFiNameBytes = wiFiName!.toBytes
         print("wifi name bytes: \(wiFiNameBytes)")
         let command = CirWirelessCommands.setSSID(ssidBytes: wiFiName!.toBytes)
         bluetoothActions?.writeCirWirelessCharacteristic(command: command, characteristic: cwProtocolWriteCharacteristic!, type: .withoutResponse)
         
     } else if protocolResponse.response == CirProtocolResponses._SSID_SUCCESSFULLY_RECEIVED.rawValue {
         
         print("SSID successfully received")
         machineState = ._SET_PASSCODE
         
     } else {
         
         print("Something wrong with SSID")
         configuringWiFiAlert.dismiss(animated: true, completion: {
             self.popUpErrorWhileConfigWiFi()
         })
         
     }
     
 case ._SET_PASSCODE :
     print("._SET_PASSCODE")
     if protocolResponse.isAPoleoPackage() {
         
         let command = CirWirelessCommands.setSSIDPasscode(ssidPasscodeBytes: wiFiPasscode!.toBytes)
         bluetoothActions?.writeCirWirelessCharacteristic(command: command, characteristic: cwProtocolWriteCharacteristic!, type: .withoutResponse)
         
     } else if protocolResponse.response == CirProtocolResponses._PASSCODE_SUCCESSFULLY_RECEIVED.rawValue {
         
         print("Passcode successfully received")
         configuringWiFiAlert.dismiss(animated: true, completion: {
             self.popUpConfigurationSuccessfullyDone()
             self.passcodeField.text = ""
         })
         machineState = ._POLING
         
     } else {
         
         configuringWiFiAlert.dismiss(animated: true, completion: {
             self.popUpErrorWhileConfigWiFi()
         })
         print("Something wrong with password")
         
     }
 }
 */
