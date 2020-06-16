//
//  ConfigurationController.swift
//  cir_wireless
//
//  Created by softel on 15/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import UIKit
import CoreBluetooth


class ConfigurationController: UIViewController {
    
    var isCirConnected = false
    var isBluetoothOn = false
    
    
    var cirWireless: CirWirelessModel?
    var bleConnection: BluetoothConnection?
    
    
    var connectingAlert: UIAlertController?
    
    
    // Outlets
    @IBOutlet weak var connectionStatus: UILabel!
    @IBOutlet weak var cirWirelessMac: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let _ = cirWireless {
            print("Everything ok")
            
            popUpConnectingCir()
            
            bleConnection = BluetoothConnection(cirToConnect: cirWireless!, connectionOptions: nil)
            bleConnection?.bleConnectionDelegate = self
            
            // MARK: IMPORTANTE: este metodo debe de ser llamado antes de cualquier conexion
            // bleConnection?.initConnection()
            
            
            
        } else {
            popUpErrorCirFound()
        }
    }
    
    
    private func goBackToRootController () {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    // MARK: Pop up area :D
    private func popUpErrorCirFound () {
        var errorCirAlert: UIAlertController?
    
        let errorCirAlertTitle = NSLocalizedString("Connection Error Title", comment: "In case the passed parameter were null")
        let errorCirAlertMessage = NSLocalizedString("Connection Error Message", comment: "Message")
        let errorCirAlertComponents = AlertComponents(alertTitle: errorCirAlertTitle, alertMessage: errorCirAlertMessage)
        let errorCirAlertAction = AlertActionComponents(buttonTitle: "Accept", buttonHandler: { _ in
            errorCirAlert?.dismiss(animated: true, completion: nil)
            self.goBackToRootController()
        })
        
        errorCirAlert = PopUpAlert.popUpOneButton(alertCharacteristic: errorCirAlertComponents, buttonCharacteristic: errorCirAlertAction)
        
        self.present(errorCirAlert!, animated: true, completion: nil)
        
    }
    
    
    private func popUpConnectingCir () {
    
        let connectingAlertTitle = NSLocalizedString("Connecting Device Title", comment: "Connectig with CIR Wireless")
        let connectingAlertMessage = NSLocalizedString("Please Wait", comment: "Message")
        let connectingAlertComponents = AlertComponents(alertTitle: connectingAlertTitle, alertMessage: connectingAlertMessage)
        let connectingAlertAction = AlertActionComponents(buttonTitle: "Cancel", buttonHandler: { _ in
            self.connectingAlert?.dismiss(animated: true, completion: nil)
            self.goBackToRootController()
        })
        
        connectingAlert = PopUpAlert.popUpOneButton(alertCharacteristic: connectingAlertComponents, buttonCharacteristic: connectingAlertAction)
        
        self.present(connectingAlert!, animated: true, completion: nil)
    }
    
    
    private func popUpCirConnected () { print("Cir connected") }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension ConfigurationController: ConnectionProtocol {
    func updateCentralState(newState: CBManagerState) {
        print("Central State: \(newState)")
        switch newState {
            
        case .unknown:
            print("")
        case .resetting:
            print("")
        case .unsupported:
            print("")
        case .unauthorized:
            print("")
        case .poweredOff:
            print("")
        case .poweredOn:
            bleConnection?.connectCirWireless()
            connectingAlert?.dismiss(animated: true, completion: nil)
            
        @unknown default:
            print("")
        }
    }
    
    func updateConnectionProcess(status: ConnectionProcess) {
        print("Connection Process Status: \(status)")
    }
    
    func errorConnectionOcurred(error: ErrorConnection) {
        print("Connection Error Ocurred: \(error)")
    }
    
    
}
