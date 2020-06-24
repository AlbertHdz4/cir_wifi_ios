//
//  CirWirelessCommands.swift
//  cir_wireless
//
//  Created by softel on 19/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import Foundation


class CirWirelessCommands {
    
    public static func openLockCommand (cirWirelessMac: [UInt8]) -> Data {
        let package = QuickCommandPackage(commandLenght: QuickCommandsLenghts._COMMAND_WITHOUT_PAYLOAD.rawValue,
                                          quickCommand: ._OPEN_LOCK).getQuickCommandPackage()
        
        let encryptedPackage = CryptoData.encryptData(reverseMac: cirWirelessMac, data: package)
        
        var data = Data()
        data.append(contentsOf: encryptedPackage)
        
        return data
    }
    
    
    public static func closeLockCommand (cirWirelessMac: [UInt8]) -> Data {
        
        let package = QuickCommandPackage(commandLenght: QuickCommandsLenghts._COMMAND_WITHOUT_PAYLOAD.rawValue,
                                          quickCommand: ._CLOSE_LOCK).getQuickCommandPackage()
        
        let encryptedPackage = CryptoData.encryptData(reverseMac: cirWirelessMac, data: package)
        
        var data = Data()
        data.append(contentsOf: encryptedPackage)
        
        return data
    }
    
    
    public static func reloadFridgeCommand (cirWirelessMac: [UInt8]) -> Data {
        let package = QuickCommandPackage(commandLenght: QuickCommandsLenghts._COMMAND_WITHOUT_PAYLOAD.rawValue,
                                          quickCommand: ._RELOAD).getQuickCommandPackage()
        
        let encryptedPackage = CryptoData.encryptData(reverseMac: cirWirelessMac, data: package)
        
        var data = Data()
        data.append(contentsOf: encryptedPackage)
        
        return data
    }
    
    
    public static func setDateCommand () -> NSData {
        
        return NSData()
    }
    
    
    public static func readDateCommand () -> NSData {
        return NSData()
    }
    
    
    public static func setWiFiSettingsCommand () -> NSData {
        return NSData()
    }
    
    
    public static func getSeenAccessPointsCommand () -> NSData {
        return NSData()
    }
    
    
    public static func getWiFiConnectionStatusCommand () -> NSData {
        return NSData()
    }
}
