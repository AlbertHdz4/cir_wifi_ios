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
        case _FIRMWARE_351 = 351
        case _FIRMWARE_352 = 352
        case _FIRMWARE_353 = 353
        case _FIRMWARE_354 = 354
        case _FIRMWARE_355 = 355
        case _FIRMWARE_357 = 357
        case _FIRMWARE_363 = 363
        case _FIRMWARE_360 = 360
        case _FIRMWARE_367 = 367
        case _FIRMWARE_382 = 382
        case _FIRMWARE_387 = 387
        case _FIRMWARE_388 = 388
        case _FIRMWARE_401 = 401
        case _FIRMWARE_402 = 402
        case _FIRMWARE_410 = 410
        case _FIRMWARE_427 = 427
        case _FIRMWARE_500 = 500
        case _FIRMWARE_501 = 501
        case _FIRMWARE_502 = 502
        case _FIRMWARE_503 = 503
        case _FIRMWARE_504 = 504
        case _FIRMWARE_505 = 505
    }
}
