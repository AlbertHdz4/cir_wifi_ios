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
    
    // Outlets
    @IBOutlet weak var courtain: CourtainView!
    
    
    var bleScan: BluetoothScan?
    var centralManager: CBCentralManager!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadViews()
        
        bleScan = BluetoothScan(filterBy: [BluetoothGattConstants.CBUUID_SERVICE_CIR_WIRELESS])
        bleScan?.bleScanDelegate = self
        bleScan?.initScan()
    }
    
    
    private func loadViews () {
        courtain.courtainMessage.text = NSLocalizedString("Scanning Devices", comment: "Scanning BLE Devices")
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
            print("unauthorized")
            
            let titleAlert = NSLocalizedString("BLE Persmission Title Denied", comment: "Permission needs to be updated")
            
            let messageAlert = NSLocalizedString("BLE Persmission Message Denied", comment: "Permission needs to be updated")
            
            var popUp: UIAlertController?
            
            let alertComponents = AlertComponents(alertTitle: titleAlert, alertMessage: messageAlert)
                        
            let actionComponents = AlertActionComponents(
                buttonTitle: NSLocalizedString("Settings", comment: "Leads user to setting values"),
                buttonHandler: {(_) -> Void in
                    let settingsUrl = URL(string: UIApplication.openSettingsURLString)
                    
                    if UIApplication.shared.canOpenURL(settingsUrl!) {
                        UIApplication.shared.open(
                            settingsUrl!,
                            completionHandler: { (success) in
                                popUp?.dismiss(animated: true, completion: nil)
                          })
                    }
            })
            
            popUp = PopUpAlert.popUpOneButton(alertCharacteristic: alertComponents,
                                              buttonCharacteristic: actionComponents)
            
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
