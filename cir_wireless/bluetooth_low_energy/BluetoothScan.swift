//
//  BluetoothScan.swift
//  cir_wireless
//
//  Created by softel on 04/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//


import Foundation
import CoreBluetooth


class BluetoothScan: NSObject {
    
    // Tunning variables
    var bleScanningTime = 5 // default 5 segundos
    
    
    // Delegates
    var bleScanDelegate: ScanProtocol?
    
    
    // Bluetooth objects
    var filterBy: [CBUUID]?
    var bleCentralState: CBManagerState?
    var bleCentralManager: CBCentralManager?

    
    var cirWirelessFound = [UUID : CirWirelessModel] ()
    
    
    init (filterBy: Array<CBUUID>) {
        self.filterBy = filterBy
    }
    
    
    func initScan () {
        bleScanDelegate?.updateScanProcessState(currentStatus: .initializing)
        bleCentralManager = CBCentralManager(delegate: self, queue: nil)
        
        if bleCentralManager != nil {
            
            bleScanDelegate?.updateScanProcessState(currentStatus: .successfullyInitiated)
            
        } else {
            
            bleScanDelegate?.updateScanProcessState(currentStatus: .unsuccessfullyInitiated)
            bleScanDelegate?.errorOcurred(error: .bleManagerNil)
        }
    }
    
    
    func scanDevices () {
        if bleCentralState == CBManagerState.poweredOn {
            bleScanDelegate?.updateScanProcessState(currentStatus: .scanning)
            
            bleCentralManager!.scanForPeripherals(withServices: filterBy,
                                                   options:[CBCentralManagerScanOptionAllowDuplicatesKey: true])
            
            Timer.scheduledTimer(timeInterval: 8, target: self, selector: #selector(self.stopScan), userInfo: nil, repeats: false)
        }
    }
    
    
    @objc func stopScan () {
        bleScanDelegate?.updateScanProcessState(currentStatus: .finished)
        bleCentralManager?.stopScan()
        /*
        var beaconStr = [String] ()
        
        for beacon in cirWirelessFound {
            let beaconData = beacon
            for beaconData in beaconData {
                beaconStr.append(String(format: "%2x", beaconData))
            }
        }*/
        
        print("SCAN FINISHED")
    }
}


// Delegates para el proceso de escaneo
extension BluetoothScan: CBCentralManagerDelegate {
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bleCentralState = central.state
        
        if let bleCentral = bleScanDelegate {
            bleCentral.updateCentralState(newState: central.state)
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("beacon: \(advertisementData)")
        
        if let beacon = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
            
            let rssiInt = integer_t (truncating: RSSI)
            let beaconModel = BeaconModel(rssi: rssiInt, beacon: beacon, advertisementData: advertisementData)
            let cirWireless = CirWirelessModel(peripheral: peripheral, peripheralId: peripheral.identifier, beacon: beaconModel)
            cirWirelessFound[]
            print("\n\n************************************")
            print("advertisementData: \(advertisementData)")
            print("beacon:size: ", beacon)
            print("peripheral: ", peripheral)
            print("RSSI: ", RSSI)
            print("dataServices: \(advertisementData["kCBAdvDataServiceUUIDs"])")
        }
    }
    
}


// Protocolo para la comunicacion entre nuestra clase Bluetooth y la clase que la llama
protocol ScanProtocol {
    
    func updateCentralState (newState: CBManagerState)
    
    
    func updateScanProcessState (currentStatus: ScanProcess)
    
    
    func scanFinished (scannedDevices: [CirWirelessModel])
    
    
    func errorOcurred (error: ErrorBluetoothScan)
}


// Posibles errores generados
enum ErrorBluetoothScan {
    case bleManagerNil
}


// Estados del proceso de escaneo
enum ScanProcess {
    case initializing
    
    case unsuccessfullyInitiated
    
    case successfullyInitiated
    
    case scanning
    
    case finished
}
