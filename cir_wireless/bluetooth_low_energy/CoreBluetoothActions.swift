//
//  BluetoothScan.swift
//  cir_wireless
//
//  Created by softel on 04/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//


import Foundation
import CoreBluetooth

/**
 * Servicio Bluetooth: Desde este servicio se manejan todos los eventos bluetooth entre iPhone y la CIR Wireless
 */
class CoreBluetoothActions: NSObject {
    
    // Tunning variables
    var scanningTime: Double?
    
    // Delegates
    var bluetoothBaseDelegate                : BluetoothBaseProtocol?
    var bluetoothScanDelegate                   : BluetoothScanProtocol?
    var bluetoothConnectionDelegate             : BluetoothConnectionProtocol?
    var bluetoothQuickCommandsDelegate          : BluetoothQuickCommandsProtocol?
    var bluetoothPolingDelegate                 : BluetoothPolingProtocol?
    
    
    // Bluetooth objects
    var uuidSerices                             : [CBUUID]?
    var bleCentralState                         : CBManagerState?
    var bleCentralManager                       : CBCentralManager!
    var cirWireless                             : CBPeripheral?
    
    
    var cirsFoundWithIBeacon                    = [UUID : CirWirelessModel] ()
    var cirsFoundWithPayloadBeacon              = [UUID : CirWirelessModel] ()
    
    
    init (filterBy uuidServices: Array<CBUUID>, scanningTime: Double = 5) {
        self.uuidSerices    = uuidServices
        self.scanningTime   = scanningTime
    }
    
    
    func initScan () {
        bluetoothBaseDelegate?.updateBluetoothActionProcess(status: .initializing)
        bleCentralManager = CBCentralManager(delegate: self, queue: nil)
        
        if bleCentralManager != nil {
            
            bluetoothBaseDelegate?.updateBluetoothActionProcess(status: .successfullyInitiated)
            
        } else {
            
            bluetoothBaseDelegate?.updateBluetoothActionProcess(status: .unsuccessfullyInitiated)
            bluetoothScanDelegate?.errorScanOcurred(error: .bleManagerNil)
            
        }
    }
    
    
    // Metodos para el proceso de escaneo -------------------------------------------------------------
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
    // -------------------------------------------------------------------------------------------------
    
    
    // Metodos para el proceso de conexion con la CIR Wireless -----------------------------------------
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
    // -------------------------------------------------------------------------------------------------
    
    
    // Metodos para la escritura y lectura de las catacteristicas ------------------------------------------------\
    func writeCirWirelessCharacteristic (command: Data, characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
        cirWireless?.writeValue(command, for: characteristic, type: type)
    }
    
    
    func readCirWirelessCharacteristic (characteristic: CBCharacteristic) {
        cirWireless?.readValue(for: characteristic)
    }
    
    
    func setCirWirelessNotifyCharacteristic (enable: Bool, notifyCharacteristic: CBCharacteristic) {
        cirWireless?.setNotifyValue(enable, for: notifyCharacteristic)
    }
    // -------------------------------------------------------------------------------------------------
}


// Delegates para el proceso de escaneo ----------------------------------------------------------------
extension CoreBluetoothActions: CBCentralManagerDelegate {
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bleCentralState = central.state
        
        if let _ = bluetoothBaseDelegate {
            bluetoothBaseDelegate!.updateCentralState(newState: central.state)
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
    
    
    // Delegados de la conexion Bluetooth ---------------------------------------------
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
        print("disconnected: error:?\(error)")
    }
    // ----------------------------------------------------------------------------------
}
// -------------------------------------------------------------------------------------------------------


// Delegados para la conexion con el dispositivo ---------------------------------------------------------
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
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Successfully written in char: ")
        let characteristicUuid = characteristic.uuid.uuidString
        bluetoothConnectionDelegate?.updateBluetoothConnectProcess(status: .successfullyWrittenInCharacteristic)
        
        if characteristicUuid == BluetoothGattConstants.CBUUID_QUICK_COMMANDS_CHARACTERISTIC {
            
            bluetoothQuickCommandsDelegate?.successfullyWrittenInCharacteristic(characteristic: characteristic, writtenValue: (characteristic.value) ?? Data())
            
        } else if characteristicUuid == BluetoothGattConstants.CBUUID_CIR_NAMA_NOTIFY_CHARACTERISTIC {
            
            bluetoothPolingDelegate?.successfullyWrittenInCharacteristic(characteristic: characteristic, writtenValue: (characteristic.value) ?? Data())
            
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        print("Successfully written in descriptor: ")
        let characteristicUuid = descriptor.characteristic.uuid.uuidString
        bluetoothConnectionDelegate?.updateBluetoothConnectProcess(status: .successfullyWrittenInDescriptor)
        
        if characteristicUuid == BluetoothGattConstants.CBUUID_QUICK_COMMANDS_CHARACTERISTIC {
            
            bluetoothQuickCommandsDelegate?.successfullyWrittenInDescriptor(descriptor: descriptor, writtenValue: (descriptor.value as! Data))
            
        } else if characteristicUuid == BluetoothGattConstants.CBUUID_CIR_NAMA_NOTIFY_CHARACTERISTIC {
            
            bluetoothPolingDelegate?.successfullyWrittenInDescriptor(descriptor: descriptor, writtenValue: (descriptor.value as! Data))
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateNotificationStateFor: ")
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // print("didUpdateValueFor: \(characteristic.value?.hexDescription)")
        let characteristicUuid = characteristic.uuid.uuidString
        
        if characteristicUuid == BluetoothGattConstants.CBUUID_DEVICE_INFO_CHARACTERISTIC {

            bluetoothQuickCommandsDelegate?.successfullyReadCharacteristic(characteristic: characteristic, readValue: characteristic.value)
            
        } else if characteristicUuid == BluetoothGattConstants.CBUUID_QUICK_COMMANDS_CHARACTERISTIC {

            bluetoothQuickCommandsDelegate?.successfullyReadCharacteristic(characteristic: characteristic, readValue: characteristic.value)
            
        } else if characteristicUuid == BluetoothGattConstants.CBUUID_CIR_NAMA_NOTIFY_CHARACTERISTIC {
            
            bluetoothPolingDelegate?.successfullyReadCharacteristic(characteristic: characteristic, readValue: characteristic.value)
            
        }

    }
}
// -------------------------------------------------------------------------------------------------


// Protocolo para la comunicacion entre nuestra clase Bluetooth y la clase que la llama ---------------
protocol BluetoothBaseProtocol {
    
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


protocol BluetoothQuickCommandsProtocol {
    
    func successfullyReadCharacteristic (characteristic: CBCharacteristic, readValue: Data?)
    
    
    func successfullyWrittenInCharacteristic (characteristic: CBCharacteristic, writtenValue: Data)
    
    
    func successfullyWrittenInDescriptor (descriptor: CBDescriptor, writtenValue: Data)
}


protocol BluetoothPolingProtocol {
    
    func successfullyReadCharacteristic (characteristic: CBCharacteristic, readValue: Data?)
    
    
    func successfullyWrittenInCharacteristic (characteristic: CBCharacteristic, writtenValue: Data)
    
    
    func successfullyWrittenInDescriptor (descriptor: CBDescriptor, writtenValue: Data)
    
}
// -------------------------------------------------------------------------------------------------


// Tamanios en bytes de los beacons mandados por la CIR Wireless -----------------------------------
enum BeaconSizes: Int {
    case iBeaconSize = 2
    
    case beaconPayloadSize = 26
}
// -------------------------------------------------------------------------------------------------


// Posibles errores generados ----------------------------------------------------------------------
enum ErrorBluetoothActions {
    
    case bleManagerNil
    
}
// -------------------------------------------------------------------------------------------------


// Posibles errores en la conexion Bluetooth -------------------------------------------------------
enum ErrorConnection {
    
    case connectionError
    
    case disconnectionError
    
}
// -------------------------------------------------------------------------------------------------



// Estados de el Bluetooth Manager -----------------------------------------------------------------
enum BluetoothActionsProcess {
    
    case initializing
    
    case unsuccessfullyInitiated
    
    case successfullyInitiated
    
}
// -------------------------------------------------------------------------------------------------


// Estados del proceso de escaneo ------------------------------------------------------------------
enum BluetoothScanProcess {
    
    case scanning
    
    case finished
    
}
// -------------------------------------------------------------------------------------------------


// Estados del proceso de conexion -----------------------------------------------------------------
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
    
    case successfullyWrittenInCharacteristic
    
    case successfullyWrittenInDescriptor
    
    case connectionFailed
}
// -------------------------------------------------------------------------------------------------
