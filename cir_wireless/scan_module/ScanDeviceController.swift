//
//  ScanDeviceController.swift
//  cir_wireless
//
//  Created by softel on 28/05/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScanDeviceController: UIViewController, ScanProtocol {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Para empezar a escanear
        let bleScan = BluetoothScan(filterBy: [BluetoothGattConstants.CBUUID_SERVICE_CIR_WIRELESS])
        bleScan.bleScanDelegate = self
        bleScan.initScan()
    }
    
    
    // Scan Protocol
    func updateCentralState(newState: CBManagerState) {
        switch newState {
            
        case .poweredOn:
            print("poweredOn")
        
            
        case .poweredOff :
            print("poweredOff")
            
            
        case .resetting :
            print("resetting")
            
            
        case .unauthorized :
            print("unauthorized")
            
            
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
