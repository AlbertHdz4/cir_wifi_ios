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
    var scanningTime: Double?
    
    // Delegates
    var bleScanDelegate: ScanProtocol?
    
    
    // Bluetooth objects
    var uuidSerices: [CBUUID]?
    var bleCentralState: CBManagerState?
    var bleCentralManager: CBCentralManager!
    
    
    var cirsFoundWithIBeacon = [UUID : CirWirelessModel] ()
    var cirsFoundWithPayloadBeacon = [UUID : CirWirelessModel] ()
    
    
    init (filterBy uuidServices: Array<CBUUID>, scanningTime: Double = 5) {
        self.uuidSerices = uuidServices
        self.scanningTime = scanningTime
    }
    
    
    func initScan () {
        bleScanDelegate?.updateScanProcessState(status: .initializing)
        bleCentralManager = CBCentralManager(delegate: self, queue: nil)
        
        if bleCentralManager != nil {
            
            bleScanDelegate?.updateScanProcessState(status: .successfullyInitiated)
            
        } else {
            
            bleScanDelegate?.updateScanProcessState(status: .unsuccessfullyInitiated)
            bleScanDelegate?.errorScanOcurred(error: .bleManagerNil)
        }
    }
    
    
    func scanDevices () {
        if bleCentralState == CBManagerState.poweredOn {
            bleScanDelegate?.updateScanProcessState(status: .scanning)
            
            bleCentralManager!.scanForPeripherals(withServices: uuidSerices,
                                                   options:[CBCentralManagerScanOptionAllowDuplicatesKey: false])
            
            Timer.scheduledTimer(timeInterval: self.scanningTime!, target: self, selector: #selector(self.stopScan), userInfo: nil, repeats: false)
        }
    }
    
    
    @objc func stopScan () {
        print("SCAN FINISHED")
        bleScanDelegate?.updateScanProcessState(status: .finished)
        bleCentralManager?.stopScan()
        
        let listOfCirWirelessFound = mergeCirsWirelessFound()
        bleScanDelegate?.scanFinished(scannedDevices: listOfCirWirelessFound)
    }
    
    
    // Mezcla ambos beacons (beaconPayload y iBeacon mandados por la CIR)
    private func mergeCirsWirelessFound () -> [CirWirelessModel] {
        var cirWirelessFound = [CirWirelessModel] ()
        
        for (peripheralUuid, cirWirelessWithIBeacon) in cirsFoundWithIBeacon {
            if let cir = cirsFoundWithPayloadBeacon[peripheralUuid] {
                cir.iBeacon = cirWirelessWithIBeacon.beacon
                cirWirelessFound.append(cir)
            }
        }
        
        return cirWirelessFound
    }
}


// MARK: Delegates para el proceso de escaneo
extension BluetoothScan: CBCentralManagerDelegate {
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bleCentralState = central.state
        
        if let delegate = bleScanDelegate {
            delegate.updateCentralState(newState: central.state)
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if let beacon = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {

            let rssiInt = integer_t (truncating: RSSI)
            let beaconModel = BeaconModel(rssi: rssiInt, beaconPayload: beacon, advertisementData: advertisementData)
            let cirWireless = CirWirelessModel(peripheral: peripheral, peripheralId: peripheral.identifier, beacon: beaconModel)
            let cirWirelessMac = (advertisementData[BeaconFields.cirWirelessMac.rawValue] as? Data)?.hexDescription
            
            if beacon.count == BeaconSizes.iBeaconSize.rawValue {
                
                if cirsFoundWithIBeacon[peripheral.identifier] == nil && cirWirelessMac != nil {
                    cirsFoundWithIBeacon[peripheral.identifier] = cirWireless
                }
                
            } else {
                
                if cirsFoundWithPayloadBeacon[peripheral.identifier] == nil {
                    cirsFoundWithPayloadBeacon[peripheral.identifier] = cirWireless
                }
                
            }
        }
    }
    
}


// MARK: Protocolo para la comunicacion entre nuestra clase Bluetooth y la clase que la llama
protocol ScanProtocol {
    
    func updateCentralState (newState: CBManagerState)
    
    
    func updateScanProcessState (status: ScanProcess)
    
    
    func scanFinished (scannedDevices: [CirWirelessModel])
    
    
    func errorScanOcurred (error: ErrorBluetoothScan)
}


// MARK: Tamanios en bytes de los beacons mandados por la CIR Wireless
enum BeaconSizes: Int {
    case iBeaconSize = 2
    
    case beaconPayloadSize = 26
}


// MARK: Posibles errores generados
enum ErrorBluetoothScan {
    case bleManagerNil
}


// MARK: Estados del proceso de escaneo
enum ScanProcess {
    case initializing
    
    case unsuccessfullyInitiated
    
    case successfullyInitiated
    
    case scanning
    
    case finished
}
