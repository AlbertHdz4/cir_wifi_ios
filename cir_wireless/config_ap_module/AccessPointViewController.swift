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
    
    let MAX_LENGTH_SSID_CHARACTERS              = 40
    let MAX_LENGTH_PASSCODE_CHARACTERS          = 20
    
    
    var isWiFiAvailable                         : Bool = false
    var wiFiName                                : String?
    
    
    var cirWireless                             : CirWirelessModel?
    var bluetoothActions                        : CoreBluetoothActions?
     
     
    // MARK: Servicios bluetooth de la cir wireless
    var cwProtocolService                       : CBService?
     
     
    // MARK: Caracteristicas bluetooth de la cir wireless
    var cwProtocolNotificationCharac            : CBCharacteristic?
    var cwProtocolWriteCharacteristic           : CBCharacteristic?
    
    
    var configuringWiFiAlert                    : UIAlertController!
    
    
    // Outlets
    @IBOutlet weak var passcodeField: UITextField!
    @IBOutlet weak var cirWirelessMac: UILabel!
    @IBOutlet weak var ssid: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadViews()
        
        if let _ = cirWireless {
            cirWirelessMac.text = cirWireless?.getCirWirelessMac()
        }
        
        
        if let wiFiName = getWiFiSsid() {
            
            self.wiFiName   = wiFiName
            ssid.text       = wiFiName
            isWiFiAvailable = true
        }
        

        passcodeField.delegate = self
        bluetoothActions?.bluetoothConnectionDelegate = self
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if wiFiName == nil {
            popUpWiFiUnavailable()
            
        }
    }
    
    
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
    
    
    // Funciones para mover el teclado al escribir en los text field --------------
    @objc func keyboardWillShow(sender: NSNotification) {
         self.view.frame.origin.y = -150 // Move view 150 points upward
    }

    
    @objc func keyboardWillHide(sender: NSNotification) {
         self.view.frame.origin.y = 0 // Move view to original position
    }
    // -----------------------------------------------------------------------------
    
    
    // Pop up Area :D --------------------------------------------------------------
    private func popUpBadPassword () {
        var badPasscodeAlert        : UIAlertController!
        
        let badPasscodeTitle        = NSLocalizedString("Bad Passcode Title", comment: "Passcode empty")
        let badPasscodeMessage      = NSLocalizedString("Bad Passcode Message", comment: "Message")
        
        let badPasscodeComponents   = AlertComponents(alertTitle: badPasscodeTitle, alertMessage: badPasscodeMessage)
        let badPasscodeActions      = AlertActionComponents(buttonTitle: NSLocalizedString("Accept", comment: ""), buttonHandler: {_ in
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
        let largeAlertActions       = AlertActionComponents(buttonTitle: NSLocalizedString("Accept", comment: ""), buttonHandler: {_ in
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
        let wiFiUnavailableActions      = AlertActionComponents(buttonTitle: NSLocalizedString("Accept", comment: ""), buttonHandler: {_ in
            wiFiAlert.dismiss(animated: true, completion: nil)
        })
        
        wiFiAlert                       = PopUpAlert.popUpOneButton(alertCharacteristic: wiFiUnavailableComponents, buttonCharacteristic: wiFiUnavailableActions)
        
        self.present(wiFiAlert, animated: true, completion: nil)
    }
    // -----------------------------------------------------------------------------
    
}


extension AccessPointViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}


extension AccessPointViewController: BluetoothConnectionProtocol {
    
    func updateBluetoothConnectProcess(status: BluetoothConnectionProcess) {
        print("status: \(status)")
    }
    
    
    func servicesAvailable(services: [CBService]?) {
        print("")
    }
    
    
    func characteristicsAvailable(service: CBService, availableCharacteristics characteristics: [CBCharacteristic]) {
        print("")
    }
    
    
    func successfullyReadCharacteristic(characteristic: CBCharacteristic, readValue: Data?) {
        print("successfullyReadCharacteristic:wiFi: ")
    }
    
    
    func successfullyWrittenInCharacteristic(characteristic: CBCharacteristic, writtenValue: Data) {
        print("successfullyWrittenInCharacteristic:wiFi: ")
    }
    
    
    func successfullyWrittenInDescriptor(descriptor: CBDescriptor, writtenValue: Data) {
        print("successfullyWrittenInDescriptor: ")
    }
    
    
    func errorConnectionOcurred(error: ErrorConnection) {
        print("errorConnectionOcurred")
    }
}
