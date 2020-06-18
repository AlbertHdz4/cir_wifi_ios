//
//  BluetoothScan.swift
//  cir_wireless
//
//  Created by softel on 04/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//


import Foundation
import CoreBluetooth


class CoreBluetoothActions: NSObject {
    
    // Tunning variables
    var scanningTime: Double?
    
    // Delegates
    var bluetoothActionsDelegate: BluetoothActionsProtocol?
    var bluetoothScanDelegate: BluetoothScanProtocol?
    var bluetoothConnectionDelegate: BluetoothConnectionProtocol?
    
    
    // Bluetooth objects
    var uuidSerices: [CBUUID]?
    var bleCentralState: CBManagerState?
    var bleCentralManager: CBCentralManager!
    var cirWireless: CBPeripheral?
    
    
    var cirsFoundWithIBeacon = [UUID : CirWirelessModel] ()
    var cirsFoundWithPayloadBeacon = [UUID : CirWirelessModel] ()
    
    
    init (filterBy uuidServices: Array<CBUUID>, scanningTime: Double = 5) {
        self.uuidSerices = uuidServices
        self.scanningTime = scanningTime
    }
    
    
    func initScan () {
        bluetoothActionsDelegate?.updateBluetoothActionProcess(status: .initializing)
        bleCentralManager = CBCentralManager(delegate: self, queue: nil)
        
        if bleCentralManager != nil {
            
            bluetoothActionsDelegate?.updateBluetoothActionProcess(status: .successfullyInitiated)
            
        } else {
            
            bluetoothActionsDelegate?.updateBluetoothActionProcess(status: .unsuccessfullyInitiated)
            bluetoothScanDelegate?.errorScanOcurred(error: .bleManagerNil)
            
        }
    }
    
    
    // MARK: Metodos para el proceso de escaneo
    func scanDevices () {
        if bleCentralState == CBManagerState.poweredOn {
            bluetoothScanDelegate?.updateBluetoothScanProcess(status: .scanning)
            
            bleCentralManager!.scanForPeripherals(withServices: uuidSerices,
                                                   options:[CBCentralManagerScanOptionAllowDuplicatesKey: false])
            
            Timer.scheduledTimer(timeInterval: self.scanningTime!, target: self, selector: #selector(self.stopScan), userInfo: nil, repeats: false)
        }
    }
    
    
    @objc func stopScan () {
        print("SCAN FINISHED")
        bluetoothScanDelegate?.updateBluetoothScanProcess(status: .finished)
        bleCentralManager?.stopScan()
        
        let listOfCirWirelessFound = mergeCirsWirelessFound()
        bluetoothScanDelegate?.scanFinished(scannedDevices: listOfCirWirelessFound)
    }
    // Metodos para el proceso de escaneo (End)
    
    
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
    // Metodos para el proceso de escaneo (End)
    
    
    // MARK: Metodos para el proceso de conexion con la CIR Wireless
    func connectCirWireless (peripheralToConnect: CBPeripheral) {
        bluetoothConnectionDelegate?.updateBluetoothConnectProcess(status: .connecting)
        cirWireless = peripheralToConnect
        cirWireless?.delegate = self
        bleCentralManager?.connect(peripheralToConnect)
    }
    
    
    func disconnectCirWireless () {
        bluetoothConnectionDelegate?.updateBluetoothConnectProcess(status: .disconnecting)
        bleCentralManager?.cancelPeripheralConnection(cirWireless!)
    }
    
    
    func discoverCirWirelessServices (specificServices services: [CBUUID]?) {
        bluetoothConnectionDelegate?.updateBluetoothConnectProcess(status: .discoveringServicesAndCharacteristics)
        cirWireless?.discoverServices(services)
    }
    
    
    func discoverCirWirelessCharacteristics (serviceToBeExamined service: CBService, specificCharacteristics: [CBUUID]?) {
        cirWireless?.discoverCharacteristics(specificCharacteristics, for: service)
    }
    // Metodos para el proceso de conexion con la CIR Wireless (End)
}


// MARK: Delegates para el proceso de escaneo
extension CoreBluetoothActions: CBCentralManagerDelegate {
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bleCentralState = central.state
        
        if let _ = bluetoothActionsDelegate {
            bluetoothActionsDelegate!.updateCentralState(newState: central.state)
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
    
    
    // MARK: Delegados de la conexion Bluetooth
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("FUCK THIS DOESN'T WORK")
        bluetoothConnectionDelegate?.updateBluetoothConnectProcess(status: .connectionFailed)
    }
    
     
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        bluetoothConnectionDelegate?.updateBluetoothConnectProcess(status: .connected)
    }
     
     
    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        print("connectionEventDidOccur: ")
    }
     
     
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Error disconnecting: ")
    }
    // Delegados de la conexion Bluetooth (End)
}


extension CoreBluetoothActions: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {

        guard let services = peripheral.services else {
                bluetoothConnectionDelegate?.updateBluetoothConnectProcess(status: .noneServicesAvailable)
                return
        }
        
        print("servicesDiscovered: ")
        bluetoothConnectionDelegate?.updateBluetoothConnectProcess(status: .servicesDiscovered)
        bluetoothConnectionDelegate?.servicesAvailable(services: services)
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        guard let characteristics = service.characteristics else {
            bluetoothConnectionDelegate?.updateBluetoothConnectProcess(status: .noneServicesAvailable)
            return
        }
        
        bluetoothConnectionDelegate?.updateBluetoothConnectProcess(status: .characteristicsDiscovered)
        bluetoothConnectionDelegate?.characteristicsAvailable(service: service, availableCharacteristics: characteristics)
    }
    
}



// MARK: Protocolo para la comunicacion entre nuestra clase Bluetooth y la clase que la llama
protocol BluetoothActionsProtocol {
    
    func updateCentralState (newState: CBManagerState)

    func updateBluetoothActionProcess (status: BluetoothActionsProcess)
}


protocol BluetoothScanProtocol {
    
    
    func updateBluetoothScanProcess (status: BluetoothScanProcess)
    
    
    func scanFinished (scannedDevices: [CirWirelessModel])
    
    
    func errorScanOcurred (error: ErrorBluetoothActions)
    
}


protocol BluetoothConnectionProtocol {
    
    func updateBluetoothConnectProcess (status: BluetoothConnectionProcess)
    
    
    func servicesAvailable (services: [CBService]?)
    
    
    func characteristicsAvailable (service: CBService, availableCharacteristics characteristics: [CBCharacteristic])
    
    
    func errorConnectionOcurred (error: ErrorConnection)
    
}
// Protocolo para la comunicacion entre nuestra clase Bluetooth y la clase que la llama (End)


// MARK: Tamanios en bytes de los beacons mandados por la CIR Wireless
enum BeaconSizes: Int {
    case iBeaconSize = 2
    
    case beaconPayloadSize = 26
}


// MARK: Posibles errores generados
enum ErrorBluetoothActions {
    
    case bleManagerNil
    
}
// Posibles errores generados (End)


// MARK: Posibles errores en la conexion Bluetooth
enum ErrorConnection {
    
    case connectionError
    
    case disconnectionError
    
}
// Posibles errores en la conexion Bluetooth (End)



// MARK: Estados de el Bluetooth Manager
enum BluetoothActionsProcess {
    
    case initializing
    
    case unsuccessfullyInitiated
    
    case successfullyInitiated
    
}


// MARK: Estados del proceso de escaneo
enum BluetoothScanProcess {
    
    case scanning
    
    case finished
    
}


enum BluetoothConnectionProcess {
    case connecting
    
    case connected
    
    case disconnecting
    
    case disconnected
    
    case discoveringServicesAndCharacteristics
    
    case servicesDiscovered
    
    case characteristicsDiscovered
    
    case noneServicesAvailable
    
    case noneCharacteristicsAvailable
    
    case connectionFailed
}
