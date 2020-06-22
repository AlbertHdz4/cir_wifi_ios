//
//  CirWirelessCommands.swift
//  cir_wireless
//
//  Created by softel on 19/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import Foundation


class CirWirelessCommands {
    
    public static func openLockCommand () -> Data {
        let command = QuickCommandPackage(
            commandLenght: QuickCommandsLenghts._COMMAND_WITHOUT_PAYLOAD.rawValue,
            quickCommand: ._OPEN_LOCK)
            .getQuickCommandPackage()
        
        var data = Data.init()
        data.append(contentsOf: command)
        
        return data
    }
    
    
    public static func closeLockCommand () -> Data {
        let command = QuickCommandPackage(
            commandLenght: QuickCommandsLenghts._COMMAND_WITHOUT_PAYLOAD.rawValue,
            quickCommand: ._CLOSE_LOCK)
            .getQuickCommandPackage()
        
        var data = Data.init()
        data.append(contentsOf: command)
        
        return data
    }
    
    
    public static func reloadFridgeCommand () -> Data {
        let command = QuickCommandPackage(
            commandLenght: QuickCommandsLenghts._COMMAND_WITHOUT_PAYLOAD.rawValue,
            quickCommand: ._RELOAD)
            .getQuickCommandPackage()
        
        var data = Data.init()
        data.append(contentsOf: command)
        
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
