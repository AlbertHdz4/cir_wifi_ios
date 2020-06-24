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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadViews()
        let wifiName = getWiFiName()
        print(wifiName)
        passcodeField.delegate = self
    }
    
    
    private func loadViews () {
        popUpConfiguring()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    // Obtenemos el nombre del WiFi al que esta conectado el iPhone ----------------
    private func getWiFiName () -> String? {
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
        
        if !(passcodeField.text?.isEmpty ?? true) {

            self.present(configuringWiFiAlert, animated: true, completion: nil)
            
        } else {
            
            popUpBadPassword()
            
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
        let badPasscodeActions      = AlertActionComponents(buttonTitle: "Accept", buttonHandler: {_ in
            badPasscodeAlert.dismiss(animated: true, completion: nil)
        })
        
        badPasscodeAlert            = PopUpAlert.popUpOneButton(alertCharacteristic: badPasscodeComponents, buttonCharacteristic: badPasscodeActions)
        
        self.present(badPasscodeAlert, animated: true, completion: nil)
    }
    
    
    private func popUpConfiguring () {
        
        let configTitle             = NSLocalizedString("Sending Passcode Title", comment: "Sending configuration to CIR")
        let configMessage           = NSLocalizedString("Please Wait", comment: "Wait")
        
        let configComponents        = AlertComponents(alertTitle: configTitle, alertMessage: configMessage)
        
        configuringWiFiAlert        = PopUpAlert.popUp(alertCharacteristic: configComponents)
        
    }
    // -----------------------------------------------------------------------------
    
}


extension AccessPointViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
    }
}
