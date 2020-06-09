//
//  TestController.swift
//  cir_wireless
//
//  Created by softel on 09/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import UIKit
import CoreBluetooth


class ScanBleController: UIViewController, ScanProtocol {
    var bleScan: BluetoothScan?
    var centralManager: CBCentralManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bleScan = BluetoothScan(filterBy: [BluetoothGattConstants.CBUUID_SERVICE_CIR_WIRELESS])
        bleScan?.bleScanDelegate = self
        bleScan?.initScan()
    }
    
    
    // Scan Protocol
    func updateCentralState(newState: CBManagerState) {
        switch newState {
        case .poweredOn:
            print("poweredOn")
            bleScan?.scanDevices()
          
          
        case .poweredOff :
            print("poweredOff")
          
          
        case .resetting :
            print("resetting")
          
          
        case .unauthorized :
            print("unauthor0ized")
            var popUp: UIAlertController?
            let components = AlertComponents(alertTitle: "A Title", alertMessage: "A Message")
            let popUpAlert = PopUpAlert(dialogCharacteristics: components)
            let actionComponents = AlertActionComponents(buttonTitle: "Ok", buttonHandler: {action in
                print("Ok pressed")
                popUp?.dismiss(animated: true, completion: nil)
            })
            
            popUp = popUpAlert.popUpOneButton(buttonCharacteristic: actionComponents)
            self.present(popUp!, animated: true, completion: nil)
          
        case .unknown :
            print("unknown")
          
          
        case .unsupported :
            print("unsupported")
          
          
        default:
            print("\(newState)")
        }
      }
      
    
      func updateScanProcessState(currentStatus: ScanProcess) {
          print("updateScanProcessState:")
      }
      
      
      func scanFinished(scannedDevices: [CirWirelessModel]) {
          print("updateScanProcessState")
      }
      
      
      func errorOcurred(error: ErrorBluetoothScan) {
          print("errorOcurred")
      }
}
