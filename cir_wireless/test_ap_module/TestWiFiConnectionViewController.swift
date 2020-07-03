//
//  TestWiFiConnectionViewController.swift
//  cir_wireless
//
//  Created by softel on 30/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import UIKit
import CoreBluetooth

class TestWiFiConnectionViewController: UIViewController {
    
    let _CHECK                          = "ic_palomita.pdf"
    let _ACCEPT                         = NSLocalizedString("Accept", comment: "")
    let _NOT_CONNECTED                  = NSLocalizedString("Not Connected", comment: "")
    
    let REPEAT_CYCLE_TIME               = 5
    let TIMEOUT                         = 30
    let TIMEOUT_RETRY_COMMAND           = 5
    
    
    var cipStatus                       = -1
    var serviceStatus                   = 0
    
    
    var bluetoothActions                : CoreBluetoothActions?
    var cirWireless                     : CirWirelessModel?
    
    
    var machineState                    : TestConnectionMachineState    = ._POLING
    var diagnosisState                  : TestConnectionStatus?

    
    // MARK: Servicios bluetooth de la cir wireless
    var cwProtocolService               : CBService?
     
     
    // MARK: Caracteristicas bluetooth de la cir wireless
    var cwProtocolNotificationCharac    : CBCharacteristic?
    var cwProtocolWriteCharacteristic   : CBCharacteristic?
    
    
    var currentCommand                  : Data?
    
    
    var diagnosingAlert                 : UIAlertController!
    var errorWhileDiagnosing            : UIAlertController!
    
    
    var assignedSsid                    : String?
    
    
    var timer                           : Timer?
    var initialTime                     : Double?
    var currentTime                     : Double?
    
    
    // Outlets
    @IBOutlet weak var iPLabel          : UILabel!
    @IBOutlet weak var ssidLabel        : UILabel!
    @IBOutlet weak var rssiLabel        : UILabel!
    @IBOutlet weak var cwMacLabel       : UILabel!
    @IBOutlet weak var apIcon           : UIImageView!
    @IBOutlet weak var internetIcon     : UIImageView!
    @IBOutlet weak var dataIcon         : UIImageView!
    
    
    // Ciclo de vida de la vista --------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        cwMacLabel.text = cirWireless?.getCirWirelessMac()
        popUpDiagnosing()
        
        if let _ = bluetoothActions {
            startTimer()
            initialTime = NSDate().timeIntervalSince1970 // Actualizamos el tiempo para ver el timeout
            currentTime = NSDate().timeIntervalSince1970
            bluetoothActions?.bluetoothBaseDelegate  = self
            bluetoothActions?.bluetoothPolingDelegate   = self
            bluetoothActions?.setCirWirelessNotifyCharacteristic(enable: true,
                                                                 notifyCharacteristic: cwProtocolNotificationCharac!)
            machineState = ._INIT_DIAGNOSIS
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.present(diagnosingAlert, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        bluetoothActions?.setCirWirelessNotifyCharacteristic(enable: false, notifyCharacteristic: cwProtocolNotificationCharac!)
    }
    // -----------------------------------------------------------
    
    
    // ------
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
            
            diagnosingAlert.dismiss(animated: true, completion: {
                print("DIAGNOSIS_STATE:TIMEOUT: \(self.diagnosisState)")
                self.machineState    = ._POLING
                self.diagnosisState  = ._DEFAULT
                self.popUpTimeout()
            })
            
            return
            
        }
        
        
        if difference > TIMEOUT_RETRY_COMMAND {
            print("**********************REWRITING**********************")
            retryCurrentCommand()
        }
        
        print("**********************OK TIMEOUT**********************")
    }
    // ----------------------------------------------------------------------------
    // -----
    
    
    func checkWiFiConnection (protocolResponse: CirProtocolResponse) {
        switch machineState {
            
        case ._POLING:
            print("POLING")
            
        case ._INIT_DIAGNOSIS:
            
            print("************************_CHECK_WIFI_STATUS************************")
            if protocolResponse.isAPoleoPackage() && cipStatus == -1 {
                
                let command = CirWirelessCommands.checkCipStatus(cirWirelessMac: (cirWireless?.getCirWirelessMacBytes())!)
                
                print("CIP Status: \(command.hexDescription)")
                bluetoothActions?.writeCirWirelessCharacteristic(command: command, characteristic: cwProtocolWriteCharacteristic!, type: .withoutResponse)
                cipStatus = -2
                
            } else if protocolResponse.response == ATResponses._AT_OK_COMMAND.rawValue {
                
                machineState    = ._CHECKING_WIFI_CONNECTION
                diagnosisState  = ._CIP_STATUS
                
            }
        case ._CHECKING_WIFI_CONNECTION:
            
            if protocolResponse.response == ATResponses._AT_COMMAND_READY.rawValue {
                
                diagnosisState(response: protocolResponse)
                
            } else {
                
                let command = CirWirelessCommands.readATStatus()
                bluetoothActions?.writeCirWirelessCharacteristic(command: command, characteristic: cwProtocolWriteCharacteristic!, type: .withoutResponse)
                
            }
        
         case ._FINISH_DIAGNOSIS:
            
            machineState = ._POLING
            stopTimerTest()
            diagnosingAlert.dismiss(animated: true, completion: {
                self.stopTimerTest()
                self.popUpAllOk()
            })
        
        case ._IS_NOT_CONFIGURING_CORRECTLY:
            machineState = ._POLING
            diagnosingAlert.dismiss(animated: true, completion: {
                self.popUpErrorWhileTesting()
            })
            
        default:
            break
        }
    }
    
    
    private func diagnosisState (response: CirProtocolResponse) {
   
        if let str = NSString(data: uInt8ToData(uintArray: response.decryptPayload(cirWirelessMac: (cirWireless?.getCirWirelessMacBytes())!)),
                              encoding: String.Encoding.utf8.rawValue) as String? {
            
            print("************************* DIAGNOSIS STATE \(diagnosisState!) *************************")
            print("************************* DATA CONNECTION STEP \(serviceStatus) *************************")
            print("************************* STRING RESPONSE: \(str) *************************")
            initialTime = NSDate().timeIntervalSince1970 // Actualizamos el tiempo para ver el timeout
            
            switch diagnosisState {
                
            case ._CIP_STATUS:
                
                print("*****************CIP_STATUS*********************")
                if str.contains(ATResponsesString._AT_STATUS.rawValue) {
                    
                    if str.contains(ATResponsesString._TCP.rawValue) {
                        
                        currentCommand = CirWirelessCommands.closeSocket(cirWirelessMac: (cirWireless?.getCirWirelessMacBytes())!)
                        
                        bluetoothActions?.writeCirWirelessCharacteristic(command: currentCommand!, characteristic: cwProtocolWriteCharacteristic!, type: .withoutResponse)
                        return
                        
                    }
                    
                    if str.contains(ATResponsesString._AT_STATUS.rawValue + ":") && str.contains(ATResponsesString._AT_OK.rawValue) {
                        
                        diagnosisState = ._MASTER_SLAVE_MODE
                        cipStatus = parseCipStatus(from: str)
                        
                        print("*****************LETS SLAVE*********************")
                        currentCommand = CirWirelessCommands.setCirInSlaveMode(cirWirelessMac: (cirWireless?.getCirWirelessMacBytes())!, mode: ._MASTER_SLAVE)
                        bluetoothActions?.writeCirWirelessCharacteristic(command: currentCommand!, characteristic: cwProtocolWriteCharacteristic!, type: .withoutResponse)
                        
                    }
                    
                }
                
                if str.contains(ATResponsesString._AT_CLOSED.rawValue) {
                    
                    diagnosisState = ._MASTER_SLAVE_MODE
                    print("*****************LETS SLAVE 2*********************")
                    currentCommand = CirWirelessCommands.setCirInSlaveMode(cirWirelessMac: (cirWireless?.getCirWirelessMacBytes())!, mode: ._MASTER_SLAVE)
                    bluetoothActions?.writeCirWirelessCharacteristic(command: currentCommand!, characteristic: cwProtocolWriteCharacteristic!, type: .withoutResponse)
                    
                }
            
            case ._MASTER_SLAVE_MODE :
                
                print("*****************_MASTER_SLAVE_MODE*********************")
                if str.contains(ATResponsesString._AT_OK.rawValue) {
                    
                    diagnosisState = ._GET_CONFIG_AP
                    print("*****************LETS _GET_CONFIG_AP*********************")
                    
                    currentCommand = CirWirelessCommands.getWiFiConfiguration(cirWirelessMac: (cirWireless?.getCirWirelessMacBytes())!)
                    bluetoothActions?.writeCirWirelessCharacteristic(command: currentCommand!, characteristic: cwProtocolWriteCharacteristic!, type: .withoutResponse)
                    
                }
                
            case ._GET_CONFIG_AP :
                
                if str.contains(ATResponsesString._AT_OK.rawValue) {
                    
                    ssidLabel.text = parseSsid(from: str)
                    diagnosisState = ._GET_STATUS_AP
                    currentCommand = CirWirelessCommands.checkConnection(cirWirelessMac: (cirWireless?.getCirWirelessMacBytes())!)
                    bluetoothActions?.writeCirWirelessCharacteristic(command: currentCommand!, characteristic: cwProtocolWriteCharacteristic!, type: .withoutResponse)
                    
                }
                
            case ._GET_STATUS_AP :
                
                print("*****************_GET_STATUS_AP*********************")
                if str.contains(ATResponsesString._AT_OK.rawValue) {
                    
                    if str.contains(ATResponsesString._AT_CW_JAP_DOTS.rawValue) {
                        
                        rssiLabel.text  = parseRssi(from: str)
                        diagnosisState  = ._GET_IP
                        currentCommand  = CirWirelessCommands.getIP(cirWirelessMac: (cirWireless?.getCirWirelessMacBytes())!)
                        bluetoothActions?.writeCirWirelessCharacteristic(command: currentCommand!, characteristic: cwProtocolWriteCharacteristic!, type: .withoutResponse)
                        
                    }
                }
                
            case ._GET_IP :
                
                print("*****************_GET_STATUS_AP*********************")
                if str.contains(ATResponsesString._AT_OK.rawValue) {
                    
                    if !str.contains(ATResponsesString._AT_IP_NOT_CONFIG.rawValue) {
                        
                        iPLabel.text    = parseIP(from: str)
                        apIcon.image    = UIImage(named: _CHECK)
                        
                        diagnosisState  = ._PING
                        currentCommand  = CirWirelessCommands.pinging(cirWirelessMac: (cirWireless?.getCirWirelessMacBytes())!, domain: _DOMAIN)
                        bluetoothActions?.writeCirWirelessCharacteristic(command: currentCommand!, characteristic: cwProtocolWriteCharacteristic!, type: .withoutResponse)
                    
                    }
                }
                
            case ._PING :
                print("*****************_PING*********************")
                
                if str.contains(ATResponsesString._AT_OK.rawValue) {
                    if (str.contains(ATResponsesString._AT_PING_INFO.rawValue) &&
                        !str.contains(ATResponsesString._AT_ERROR.rawValue)) {
                        
                        serviceStatus           = 0
                        diagnosisState          = ._DATA_CONNECTION
                        internetIcon.image      = UIImage(named: _CHECK)
                        currentCommand          = CirWirelessCommands.closeSocket(cirWirelessMac: (cirWireless?.getCirWirelessMacBytes())!)
                        bluetoothActions?.writeCirWirelessCharacteristic(command: currentCommand!, characteristic: cwProtocolWriteCharacteristic!, type: .withoutResponse)
                        
                    }
                }
                
            case ._DATA_CONNECTION:
                print("*****************_DATA_CONNECTION*********************")

                switch serviceStatus {
                    
                case 0:
                
                    serviceStatus   = 1
                    currentCommand  = CirWirelessCommands.openSocket(cirWirelessMac: (cirWireless?.getCirWirelessMacBytes())!, server: _FOOD_SERVICE_DOMAIN, port: _PORT)
                    bluetoothActions?.writeCirWirelessCharacteristic(command: currentCommand!, characteristic: cwProtocolWriteCharacteristic!, type: .withoutResponse)
                
                case 1:
                    
                    if str.contains(ATResponsesString._AT_OK.rawValue) && str.contains(ATResponsesString._AT_CONNECT.rawValue) {
                        
                        serviceStatus = 2
                        currentCommand = CirWirelessCommands.closeSocket(cirWirelessMac: (cirWireless?.getCirWirelessMacBytes())!)
                        bluetoothActions?.writeCirWirelessCharacteristic(command: currentCommand!, characteristic: cwProtocolWriteCharacteristic!, type: .withoutResponse)

                    }
                    
                    
                
                case 2:
                    
                    if str.contains(ATResponsesString._AT_CLOSED.rawValue) && str.contains(ATResponsesString._AT_OK.rawValue) {
                        
                        dataIcon.image = UIImage(named: _CHECK)
                        
                        serviceStatus   = 0
                        diagnosisState  = ._DEFAULT
                        machineState    = ._FINISH_DIAGNOSIS
                        
                    }
                    
                default:
                    break
                }
                
            default:
                break
                
            }
            
        }
    }

    
    // Reenviamos el comando actual a la CIR Wireless
    private func retryCurrentCommand () {
        if let _ = currentCommand {
            bluetoothActions?.writeCirWirelessCharacteristic(command: currentCommand!, characteristic: cwProtocolWriteCharacteristic!, type: .withoutResponse)
        }
    }
    
    
    // Parseadores --------------------------------------------------------------------------------------
    private func parseIP (from: String) -> String {
        let array = from.components(separatedBy: "\"")
        return String(array[5].replacingOccurrences(of: "\"", with: "", options: .literal))
    }
    
    
    private func parseCipStatus (from: String) -> Int {
        let array = from.components(separatedBy: ":")
        let cip = array[1][0]
        return Int(cip)!
    }
    
    
    private func parseSsid (from: String) -> String {
        let array = from.components(separatedBy: "\"")
        let ssid = array[1]
        return String(ssid.substring(fromIndex: 3))
    }
    
    
    private func parseRssi (from: String) -> String {
        let array = from.components(separatedBy: ",")
        return String(array[3])
    }
    // ----------------------------------------------------------------------------------------------------
    
    
    // Pop up area ----------------------------------------------------------------------------------------
    private func popUpDiagnosing () {
          
        let diagnosingTitle           = NSLocalizedString("Diagnosing Connection", comment: "Doing test")
        let diagnosingMessage         = NSLocalizedString("Wait Minutes", comment: "Wait")
          
        let diagnosingComponents      = AlertComponents(alertTitle: diagnosingTitle, alertMessage: diagnosingMessage)
          
        diagnosingAlert               = PopUpAlert.popUp(alertCharacteristic: diagnosingComponents)
    }
    
    
    private func popUpErrorWhileTesting () {
        var errorAlert              : UIAlertController!
        
        let errorOcurredTitle       = NSLocalizedString("Error Ocurred Title", comment: "SSID or Passcode is not correct")
        let errorOcurredMessage     = NSLocalizedString("Error Ocurred Message", comment: "")
        
        let errorComponents         = AlertComponents(alertTitle: errorOcurredTitle, alertMessage: errorOcurredMessage)
        let errorActions            = AlertActionComponents(buttonTitle: _ACCEPT, buttonHandler: {_ in
            errorAlert.dismiss(animated: true, completion: nil)
        })
        
        errorAlert                  = PopUpAlert.popUpOneButton(alertCharacteristic: errorComponents, buttonCharacteristic: errorActions)
        
        self.present(errorAlert, animated: true, completion: nil)
        
    }
    
    
    private func popUpMissConfiguration () {
        var missConfigAlert         : UIAlertController!
        
        let missConfigTitle       = NSLocalizedString("Missed Configuration", comment: "CIR Wireless is not correctly configured")
        let missConfigMessage     = NSLocalizedString("Missed Configuration Message", comment: "")
        
        let missConfigComponents  = AlertComponents(alertTitle: missConfigTitle, alertMessage: missConfigMessage)
        let missConfigActions     = AlertActionComponents(buttonTitle: _ACCEPT, buttonHandler: {_ in
            missConfigAlert.dismiss(animated: true, completion: nil)
        })
        
        missConfigAlert           = PopUpAlert.popUpOneButton(alertCharacteristic: missConfigComponents, buttonCharacteristic: missConfigActions)
        
        self.present(missConfigAlert, animated: true, completion: nil)
        
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
    
    
    private func popUpAllOk () {
        var allOkAlert          : UIAlertController!
           
        let allOkTitle          = NSLocalizedString("Diagnosis Result", comment: "All Good :D")
        let allOkMessage        = NSLocalizedString("Diagnosis Result Message", comment: "")
           
        let allOkComponents     = AlertComponents(alertTitle: allOkTitle, alertMessage: allOkMessage)
        let allOkActions        = AlertActionComponents(buttonTitle: _ACCEPT, buttonHandler: {_ in
            allOkAlert.dismiss(animated: true, completion: nil)
        })
           
        allOkAlert           = PopUpAlert.popUpOneButton(alertCharacteristic: allOkComponents, buttonCharacteristic: allOkActions)
           
        self.present(allOkAlert, animated: true, completion: nil)
    }
    // ----------------------------------------------------------------------------------------------------
}


extension TestWiFiConnectionViewController: BluetoothBaseProtocol {
    func updateCentralState(newState: CBManagerState) {
        print("updateCentralState: ")
    }
    
    func updateBluetoothActionProcess(status: BluetoothActionsProcess) {
        print("updateBluetoothActionProcess: ")
    }
    
    
}


extension TestWiFiConnectionViewController: BluetoothPolingProtocol {
    
    func successfullyReadCharacteristic(characteristic: CBCharacteristic, readValue: Data?) {
        // print("TestWiFi:successfullyReadCharacteristic: ")
        let characteristicUuidString = characteristic.uuid.uuidString
        
        if characteristicUuidString == cwProtocolNotificationCharac?.uuid.uuidString, let response = readValue {
            // print("response: \(response.hexDescription)")
            let protocolResponse = CirProtocolResponse(protocolResponse: response.hexDescription.hexaToBytes)
            checkWiFiConnection(protocolResponse: protocolResponse)
        }
    }
    
    
    func successfullyWrittenInCharacteristic(characteristic: CBCharacteristic, writtenValue: Data) {
        print("TestWiFi:successfullyWrittenInCharacteristic: ")
    }
    
    
    func successfullyWrittenInDescriptor(descriptor: CBDescriptor, writtenValue: Data) {
        print("TestWiFi:successfullyWrittenInDescriptor: ")
    }
    
}


enum TestConnectionMachineState: Int {
    
    case _POLING
    
    case _WIFI_CONFIGURING
    
    case _WIFI_NOT_CONNECTED
    
    case _WIFI_SSID_FAILED
    
    case _WIFI_CONNECTING
    
    case _WIFI_CONNECTED
    
    case _WIFI_IP_FAILED
    
    case _WIFI_GET_LOCATION
    
    case _WIFI_INTERNET_READY
    
    case _WIFI_TRANSMITING
    
    case _INIT_DIAGNOSIS
    
    case _CHECKING_WIFI_CONNECTION
    
    case _IS_NOT_CONFIGURING_CORRECTLY
    
    case _FINISH_DIAGNOSIS
}



enum TestConnectionStatus {
    case _MASTER_SLAVE_MODE
    
    case _SLAVE_MODE
    
    case _SET_MODE
    
    case _GET_CONFIG_AP
    
    case _GET_STATUS_AP
    
    case _GET_IP
    
    case _GET_PING
    
    case _PING
    
    case _DATA_CONNECTION
    
    case _CIP_STATUS
    
    case _DEFAULT
}

/*
 case ._SET_MODE:
     print("************************_SET_MODE************************")
     
 case ._GET_CONFIG_AP:
     print("************************_GET_CONFIG_AP************************")
     
 case ._GET_STATUS_AP:
     print("************************_GET_STATUS_AP************************")
     
 case ._GET_IP:
     print("************************_GET_IP************************")
     
 case ._GET_PING:
     print("************************_GET_PING************************")
     
 case ._PING:
     print("************************_PING************************")
     
 case ._DATA_CONNECTION:
     print("************************_DATA_CONNECTION************************")

 case ._MASTER_SLAVE_MODE:
     print("************************_MASTER_SLAVE_MODE************************")
 */
