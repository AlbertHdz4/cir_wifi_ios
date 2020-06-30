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
                                          quickCommand: ._OPEN_LOCK)
        
        let encryptedPackage = CryptoData.encryptData(reverseMac: cirWirelessMac, data: package.fullPackage)
        
        var data = Data()
        data.append(contentsOf: encryptedPackage)
        
        return data
    }
    
    
    public static func closeLockCommand (cirWirelessMac: [UInt8]) -> Data {
        
        let package = QuickCommandPackage(commandLenght: QuickCommandsLenghts._COMMAND_WITHOUT_PAYLOAD.rawValue,
                                          quickCommand: ._CLOSE_LOCK)
        
        let encryptedPackage = CryptoData.encryptData(reverseMac: cirWirelessMac, data: package.fullPackage)
        
        var data = Data()
        data.append(contentsOf: encryptedPackage)
        
        return data
    }
    
    
    public static func reloadFridgeCommand (cirWirelessMac: [UInt8]) -> Data {
        let package = QuickCommandPackage(commandLenght: QuickCommandsLenghts._COMMAND_WITHOUT_PAYLOAD.rawValue,
                                          quickCommand: ._RELOAD)
        
        let encryptedPackage = CryptoData.encryptData(reverseMac: cirWirelessMac, data: package.fullPackage)
        
        var data = Data()
        data.append(contentsOf: encryptedPackage)
        return data
    }
    
    
    public static func setDateCommand (cirWirelessMac: [UInt8], dateBytes: [UInt8]) -> Data {
        let package = QuickCommandPackage(commandLenght: QuickCommandsLenghts._COMMAND_WITH_DATE.rawValue,
                                          quickCommand: ._SET_DATE,
                                          payload: dateBytes)
        
        let encryptedData = CryptoData.encryptData(reverseMac: cirWirelessMac, data: package.fullPackage)
        
        var data = Data()
        data.append(contentsOf: encryptedData)
        return data
    }
    
    
    public static func readDateCommand (cirWirelessMac: [UInt8]) -> Data {
        let package = QuickCommandPackage(commandLenght: QuickCommandsLenghts._COMMAND_WITHOUT_PAYLOAD.rawValue,
                                          quickCommand: ._READ_DATE)
        
        let encryptedData = CryptoData.encryptData(reverseMac: cirWirelessMac, data: package.fullPackage)
        
        var data = Data()
        data.append(contentsOf: encryptedData)
        return data
    }
    
    
    public static func resetWiFiTask () -> Data {
        let package = CirProtocolPackage(preambulo: ._PREAMBULO, destino: ._DESTINO, origen: ._ORIGEN,
                                         packageLength: CirProtocolCommmonLengths._BASE_PACKAGE_LENGTH.rawValue,
                                         command: ._RESET_WIFI_TASK, payload: nil)
        
        var data = Data()
        data.append(contentsOf: package.fullPackage)
        return data
    }
    
    
    public static func setSSID (cirWirelessMac: [UInt8], ssidBytes: [UInt8]!) -> Data {
        let packageLength = Int(CirProtocolCommmonLengths._BASE_PACKAGE_LENGTH.rawValue) + ssidBytes.count
        let packageLengthBytes = packageLength.toByteArray(size: 1)
        
        let package = CirProtocolPackage(preambulo: ._PREAMBULO, destino: ._DESTINO, origen: ._ORIGEN,
                                         packageLength: packageLengthBytes[0], command: ._SET_SSID, payload: ssidBytes)
        
        // let encryptedPackage = CryptoData.encryptData(reverseMac: cirWirelessMac, data: package.fullPackage)
        
        var data = Data()
        data.append(contentsOf: package.fullPackage)
        return data
    }
    
    
    public static func setSSIDPasscode (cirWirelessMac: [UInt8], ssidPasscodeBytes: [UInt8]!) -> Data {
        let packageLength = Int(CirProtocolCommmonLengths._BASE_PACKAGE_LENGTH.rawValue) + ssidPasscodeBytes.count
        let packageLengthBytes = packageLength.toByteArray(size: 1)
        
        let package = CirProtocolPackage(preambulo: ._PREAMBULO, destino: ._DESTINO, origen: ._ORIGEN,
                                         packageLength: packageLengthBytes[0], command: ._SET_SSID_PASSCODE, payload: ssidPasscodeBytes)
        
        // let encryptedPackage = CryptoData.encryptData(reverseMac: cirWirelessMac, data: package.fullPackage)
        
        var data = Data()
        data.append(contentsOf: package.fullPackage)
        return data
    }
    
    
    public static func getSeenAccessPointsCommand () -> Data {
        let package = CirProtocolPackage(preambulo: ._PREAMBULO, destino: ._DESTINO, origen: ._ORIGEN,
                                         packageLength: CirProtocolCommmonLengths._BASE_PACKAGE_LENGTH.rawValue,
                                         command: ._GET_AP_LIST, payload: nil)
        
        var data = Data()
        data.append(contentsOf: package.fullPackage)
        print(data.hexDescription)
        return data
    }
    
    
    public static func getWiFiConnectionStatusCommand () -> Data {
        let package = CirProtocolPackage(preambulo: ._PREAMBULO, destino: ._DESTINO, origen: ._ORIGEN,
                                         packageLength: CirProtocolCommmonLengths._BASE_PACKAGE_LENGTH.rawValue,
                                         command: ._TEST_WIFI_CONNECTION, payload: nil)
        var data = Data()
        data.append(contentsOf: package.fullPackage)
        return data
    }
}
