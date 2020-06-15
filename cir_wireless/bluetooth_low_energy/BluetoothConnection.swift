//
//  BluetoothConnection.swift
//  cir_wireless
//
//  Created by softel on 15/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import Foundation
import CoreBluetooth


class BluetoothConnection: NSObject {
    
    var cirWireless: CirWirelessModel?
    
    
    var bleCentralState: CBManagerState?
    var bleCentralManager: CBCentralManager!
    var bleConnectionDelegate: ConnectionProtocol?
    
    
    var connectionOptions: [String : Any]?
    
    
    init (cirToConnect cirWireless: CirWirelessModel, connectionOptions options: [String : Any]?) {
        self.cirWireless = cirWireless
        self.connectionOptions = options
    }
    
    
    // MARK: Este metodo debe ser ejecutado antes de cualquier conexion
    func initConnection () {
        bleConnectionDelegate?.updateConnectionProcess(status: .initializing)
        bleCentralManager = CBCentralManager(delegate: self, queue: nil)
         
        if bleCentralManager != nil {
             
            bleConnectionDelegate?.updateConnectionProcess(status: .successfullyInitiated)
             
        } else {
             
            bleConnectionDelegate?.updateConnectionProcess(status: .unsuccessfullyInitiated)
            bleConnectionDelegate?.errorConnectionOcurred(error: .bleManagerNil)
        }
     }
    
    
    func connectCirWireless () {
        bleConnectionDelegate?.updateConnectionProcess(status: .connecting)
        print("Beacon: \(cirWireless?.beacon?.beaconString)")
        print("Peripheral: \(cirWireless?.peripheral)")
        bleCentralManager.connect(cirWireless!.peripheral!)
    }
}


// MARK: Delegates para la conexion Bluetooth
extension BluetoothConnection: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bleCentralState = central.state
        
        if let bleCentral = bleConnectionDelegate {
            bleCentral.updateCentralState(newState: central.state)
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        bleConnectionDelegate?.updateConnectionProcess(status: .connected)
        print("Connected ... ")
        
    }
    
}
// Delegates para la conexion Bluetooth (End)


// MARK: Protocolo para comunicar vista y conexion
protocol ConnectionProtocol {
    
    func updateCentralState (newState: CBManagerState)
    
    
    func updateConnectionProcess (status: ConnectionProcess)
 
    
    func errorConnectionOcurred (error: ErrorConnection)
    
}
// Protocolo para comunicar vista y conexion (End)


// MARK: Posibles errores en la conexion Bluetooth
enum ErrorConnection {
    
    case bleManagerNil
    
    
    case connectionError
    
    
    case disconnectionError
    
}
// Posibles errores en la conexion Bluetooth (End)


// MARK: Proceso de conexion Bluetooth
enum ConnectionProcess {
    
    case initializing
    
    
    case unsuccessfullyInitiated
    
    
    case successfullyInitiated
    
    
    case connecting
    
    
    case connected
    
    
    case disconnecting
    
    
    case disconnected
    
    
    case discoveringServicesAndCharacteristics
    
}
// Proceso de conexion Bluetooth (End)
