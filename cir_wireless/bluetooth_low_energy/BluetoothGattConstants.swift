//
//  BluetoothGattConstants.swift
//  cir_wireless
//
//  Created by softel on 05/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothGattConstants {
    
    // Bluetooth services
    public static let CBUUID_CIR_NAMA_SERVICE               = "8f8339dd-3528-45b0-b5bf-9233a51bd1e0".uppercased()
    public static let CBUUID_DEVICE_INFO_SERVICE            = "00010000-0000-1000-8000-00805f9baaaa".uppercased()
    public static let CBUUID_QUICK_COMMANDS_SERVICE         = "00090000-0000-1000-8000-00805f9baaaa".uppercased()


    // Bluetooth Characteristics
    public static let CBUUID_CIR_NAMA_NOTIFY_CHARACTERISTIC = "8f8339de-3528-45b0-b5bf-9233a51bd1e0".uppercased()
    public static let CBUUID_CIR_NAMA_WRITE_CHARACTERISTIC  = "8f8339df-3528-45b0-b5bf-9233a51bd1e0".uppercased()
    public static let CBUUID_DEVICE_INFO_CHARACTERISTIC     = "00010002-0000-1000-8000-00805f9baaaa".uppercased()
    public static let CBUUID_QUICK_COMMANDS_CHARACTERISTIC  = "00090001-0000-1000-8000-00805f9baaaa".uppercased()
    
    
    // Bluetooth descriptors
    public static let NOTIFICATION_DESCRIPTOR               = "00002902-0000-1000-8000-00805f9b34fb".uppercased()


    // Identificadores de los servicios BLE
    public static let CBUUID_SERVICE_CIR_WIRELESS : CBUUID  = CBUUID(string: "00050000-0000-1000-8000-00805f9baaaa")
    
    
    enum AllowedFirmwares: Int {
        
        case _FIRMWARE_350 = 350
        
    }
}
