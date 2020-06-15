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
    
    var cirWireless: CirWirelessModel?
    
    
    var bleConnection: BluetoothConnection?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let _ = cirWireless {
            
            print("Everything ok")
            bleConnection = BluetoothConnection(cirToConnect: cirWireless!, connectionOptions: nil)
            bleConnection?.bleConnectionDelegate = self
            
            // MARK: IMPORTANTE: este metodo debe de ser llamado antes de cualquier conexion
            bleConnection?.initConnection()

            
        } else {
            popUpErrorCirFound()
        }
    }
    
    
    // MARK: Pop up area :D
    private func popUpErrorCirFound () { print("Cir wireless is nil") }

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
