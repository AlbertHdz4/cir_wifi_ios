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
    private let CBUUID_SERVICE_CIR_WIRELESS : CBUUID = CBUUID(string: "00050000-0000-1000-8000-00805f9baaaa")

    
    // Tunning variables
    var bleScanningTime = 5 // default 5 segundos
    
    
    // Delegates
    var bleScanDelegate: ScanProtocol?
    
    
    // Bluetooth objects
    var beacons = [Data] ()
    var scanFilters: [CBUUID]?
    var bleCentralState: CBManagerState?
    var bleCentralManager: CBCentralManager?
    
    
    init (scanFilter: Array<CBUUID>, bleCentralManager: CBCentralManager) {
        self.scanFilters = scanFilter
        self.bleCentralManager = bleCentralManager
    }
    
    
    func initScan () {
        bleScanDelegate?.updateScanProcess(currentStatus: .initializing)
        
        bleCentralManager = CBCentralManager(delegate: self, queue: nil)
        
        if bleCentralManager == nil {
            bleScanDelegate?.errorOcurred(error: .bleManagerNil)
            return
        }
    }
    
    
    func scanDevices () {
        if bleCentralState == CBManagerState.poweredOn {
            bleScanDelegate?.updateScanProcess(currentStatus: .scanning)
            
            bleCentralManager!.scanForPeripherals(withServices: [CBUUID_SERVICE_CIR_WIRELESS],
                                                   options:[CBCentralManagerScanOptionAllowDuplicatesKey: true])
            
            Timer.scheduledTimer(timeInterval: 8, target: self, selector: #selector(self.stopScan), userInfo: nil, repeats: false)
        }
    }
    
    
    @objc func stopScan () {
        bleScanDelegate?.updateScanProcess(currentStatus: .finished)
        bleCentralManager?.stopScan()
        
        var beaconStr = [String] ()
        
        for beacon in beacons {
            let beaconData = beacon
            for beaconData in beaconData {
                beaconStr.append(String(format: "%2x", beaconData))
            }
        }
        
        print("BEACON STR SAVED: ", beaconStr)
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
        if let beacon = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
            let beaconStr : String = advertisementData[CBAdvertisementDataManufacturerDataKey] as? String ?? "NO DATA"
            let rssiInteger = integer_t (RSSI)
            let dataServices = advertisementData[CBAdvertisementDataServiceUUIDsKey]
            print("\n\n************************************")
            print("advertisementData: \(advertisementData)")
            print("beacon:size: ", beacon)
            print("peripheral: ", peripheral)
            print("RSSI: ", RSSI)
            print("dataServices: \(advertisementData["kCBAdvDataServiceUUIDs"])")
            
            if dataServices != nil   {

                beacons.append(beacon)
                
            }
        }
    }
    
}


// Protocolo para la comunicacion entre nuestra clase Bluetooth y la clase que la llama
protocol ScanProtocol {
    
    func updateCentralState (newState: CBManagerState)
    
    
    func updateScanProcess (currentStatus: ScanProcess)
    
    
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
    
    case scanning
    
    case finished
}
