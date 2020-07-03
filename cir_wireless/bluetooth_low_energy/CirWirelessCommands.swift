//
//  CirWirelessCommands.swift
//  cir_wireless
//
//  Created by softel on 19/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import Foundation


class CirWirelessCommands {
    
    private static let _NULL: UInt8 = 0x00
    
    public static func openLockCommand (cirWirelessMac: [UInt8]) -> Data {
        let package             = QuickCommandPackage(commandLenght: QuickCommandsLenghts._COMMAND_WITHOUT_PAYLOAD.rawValue,
                                          quickCommand: ._OPEN_LOCK)
        
        let encryptedPackage    = CryptoData.encryptData(reverseMac: cirWirelessMac, data: package.fullPackage)
        
        var data = Data()
        data.append(contentsOf: encryptedPackage)
        
        return data
    }
    
    
    public static func closeLockCommand (cirWirelessMac: [UInt8]) -> Data {
        
        let package             = QuickCommandPackage(commandLenght: QuickCommandsLenghts._COMMAND_WITHOUT_PAYLOAD.rawValue,
                                          quickCommand: ._CLOSE_LOCK)
        
        let encryptedPackage    = CryptoData.encryptData(reverseMac: cirWirelessMac, data: package.fullPackage)
        
        var data = Data()
        data.append(contentsOf: encryptedPackage)
        
        return data
    }
    
    
    public static func reloadFridgeCommand (cirWirelessMac: [UInt8]) -> Data {
        let package             = QuickCommandPackage(commandLenght: QuickCommandsLenghts._COMMAND_WITHOUT_PAYLOAD.rawValue,
                                          quickCommand: ._RELOAD)
        
        let encryptedPackage    = CryptoData.encryptData(reverseMac: cirWirelessMac, data: package.fullPackage)
        
        var data = Data()
        data.append(contentsOf: encryptedPackage)
        return data
    }
    
    
    public static func setDateCommand (cirWirelessMac: [UInt8], dateBytes: [UInt8]) -> Data {
        
        let package         = QuickCommandPackage(commandLenght: QuickCommandsLenghts._COMMAND_WITH_DATE.rawValue,
                                          quickCommand: ._SET_DATE,
                                          payload: dateBytes)
        let encryptedData   = CryptoData.encryptData(reverseMac: cirWirelessMac, data: package.fullPackage)
        
        var data = Data()
        data.append(contentsOf: encryptedData)
        return data
    }
    
    
    public static func readDateCommand (cirWirelessMac: [UInt8]) -> Data {
        
        let package         = QuickCommandPackage(commandLenght: QuickCommandsLenghts._COMMAND_WITHOUT_PAYLOAD.rawValue,
                                          quickCommand: ._READ_DATE)
        let encryptedData   = CryptoData.encryptData(reverseMac: cirWirelessMac, data: package.fullPackage)
        
        var data = Data()
        data.append(contentsOf: encryptedData)
        return data
    }
    
    
    public static func setSSID (ssidBytes: [UInt8]!) -> Data {
        
        let packageLength           = Int(CirProtocolCommmonLengths._BASE_PACKAGE_LENGTH.rawValue) + ssidBytes.count
        let packageLengthBytes      = packageLength.toByteArray(size: 1)
        let package                 = CirProtocolPackage(preambulo: ._PREAMBULO, destino: ._DESTINO, origen: ._ORIGEN,
                                         packageLength: packageLengthBytes[0], command: ._SET_SSID, payload: ssidBytes)
        
        var data = Data()
        data.append(contentsOf: package.fullPackage)
        return data
    }
    
    
    public static func setSSIDPasscode (ssidPasscodeBytes: [UInt8]!) -> Data {
        let packageLength           = Int(CirProtocolCommmonLengths._BASE_PACKAGE_LENGTH.rawValue) + ssidPasscodeBytes.count
        let packageLengthBytes      = packageLength.toByteArray(size: 1)
        
        let package                 = CirProtocolPackage(preambulo: ._PREAMBULO, destino: ._DESTINO, origen: ._ORIGEN,
                                         packageLength: packageLengthBytes[0], command: ._SET_SSID_PASSCODE, payload: ssidPasscodeBytes)
        
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
    
    
    // AT Commands ----------------------------------------------------------------------------------------------------
    public static func setCirInSlaveMode (cirWirelessMac: [UInt8], mode: ATModes) -> Data {
    
        var aTCommand               = (ATPrefixes._AT_CW_MODE.rawValue + "\(mode.rawValue)").toBytes
        aTCommand.append(_NULL) // NULL Value requerido por el protocolo de comandos AT
        
        return formAtPackage(cirWirelessMac: cirWirelessMac, aTCommand: aTCommand)
    }
    
    
    public static func resetWiFiTask (cirWirelessMac: [UInt8]) -> Data {
        var aTCommand           = (ATPrefixes._RESET_WIFI.rawValue).toBytes
        aTCommand.append(_NULL)
        
        return formAtPackage(cirWirelessMac: cirWirelessMac, aTCommand: aTCommand)
    }
    
    
    public static func setAPName (cirWirelessMac: [UInt8], ssid: String, passcode: String, flag: Int) -> Data {
        var aTCommand           = (ATPrefixes._AT_CW_SAP.rawValue + "\"ID_\(ssid)\",\"\(passcode)\",6,0,4,\(flag)").toBytes
        aTCommand.append(_NULL)
        
        return formAtPackage(cirWirelessMac: cirWirelessMac, aTCommand: aTCommand)
    }
    
    
    public static func setAutoConnect (cirWirelessMac: [UInt8], enable: Int) -> Data {
        var aTCommand           = (ATPrefixes._AT_CW_AUTOCONN.rawValue + "\(enable)").toBytes
        aTCommand.append(_NULL)
        
        return formAtPackage(cirWirelessMac: cirWirelessMac, aTCommand: aTCommand)
    }
    
    
    public static func setWiFiConfiguration (cirWirelessMac: [UInt8], ssid: String, passcode: String) -> Data {
        var aTCommand           = (ATPrefixes._AT_CW_JAP.rawValue + "\"\(ssid)\",\"\(passcode)\"").toBytes
        aTCommand.append(_NULL)
        
        return formAtPackage(cirWirelessMac: cirWirelessMac, aTCommand: aTCommand)
    }
    
    
    public static func readATStatus () -> Data {
        let package = CirProtocolPackage(preambulo: ._PREAMBULO, destino: ._DESTINO, origen: ._ORIGEN,
                                         packageLength: CirProtocolCommmonLengths._BASE_PACKAGE_LENGTH.rawValue,
                                         command: ._READ_AT_RESULT, payload: nil)
        var data = Data()
        data.append(contentsOf: package.fullPackage)
        print("readATStatus \(data.hexDescription)")
        return data
    }
    // ----------------------------------------------------------------------------------------------------
    
    
    // AT commands para el estatus de conexion ------------------------------------------------------------
    public static func checkCipStatus (cirWirelessMac: [UInt8]) -> Data {
        var aTCommand = (ATPrefixes._AT_CIP_STATUS.rawValue).toBytes
        aTCommand.append(_NULL)
        
       return formAtPackage(cirWirelessMac: cirWirelessMac, aTCommand: aTCommand)
    }
    
    
    public static func closeSocket (cirWirelessMac: [UInt8]) -> Data {
        var aTCommand = (ATPrefixes._AT_CIP_CLOSE.rawValue).toBytes
        aTCommand.append(_NULL)
        
        return formAtPackage(cirWirelessMac: cirWirelessMac, aTCommand: aTCommand)
    }
    
    
    public static func openSocket (cirWirelessMac: [UInt8], server: String, port: String) -> Data {
        var aTCommand = (ATPrefixes._AT_CIP_START.rawValue + "\"\(server)\",\(port)").toBytes
        aTCommand.append(_NULL)
        return formAtPackage(cirWirelessMac: cirWirelessMac, aTCommand: aTCommand)
    }
    
    
    public static func getWiFiConfiguration (cirWirelessMac: [UInt8]) -> Data {
        var aTCommand = (ATPrefixes._AT_CW_SAP.rawValue).toBytes
        aTCommand.append(_NULL)
        
        return formAtPackage(cirWirelessMac: cirWirelessMac, aTCommand: aTCommand)
    }
    
    
    public static func checkConnection (cirWirelessMac: [UInt8]) -> Data {
        var aTCommand = (ATPrefixes._AT_CW_JAP.rawValue).toBytes
        aTCommand.append(_NULL)
        
        return formAtPackage(cirWirelessMac: cirWirelessMac, aTCommand: aTCommand)
        
    }
    
    public static func getIP (cirWirelessMac: [UInt8]) -> Data {
        var aTCommand = (ATPrefixes._AT_CIF_SR.rawValue).toBytes
        aTCommand.append(_NULL)
        
        return formAtPackage(cirWirelessMac: cirWirelessMac, aTCommand: aTCommand)
    }
    
    
    public static func pinging (cirWirelessMac: [UInt8], domain: String) -> Data {
        var aTCommand = (ATPrefixes._AT_PING.rawValue + "\"\(domain)\"").toBytes
        aTCommand.append(_NULL)
        
        return formAtPackage(cirWirelessMac: cirWirelessMac, aTCommand: aTCommand)
    }
    // ----------------------------------------------------------------------------------------------------
    
    
    // Util para formar el paquete de los AT commands
    private static func formAtPackage (cirWirelessMac: [UInt8], aTCommand: [UInt8]) -> Data {
        let packageLength = Int(CirProtocolCommmonLengths._BASE_PACKAGE_LENGTH.rawValue) + aTCommand.count
        let packageLengthBytes = packageLength.toByteArray(size: 1)[0]
        
        let encryptedData = CryptoData.encryptData(reverseMac: cirWirelessMac, data: aTCommand)
        let package             = CirProtocolPackage(preambulo: ._PREAMBULO, destino: ._DESTINO, origen: ._ORIGEN,
                                                 packageLength: packageLengthBytes, command: ._GENERIC_AT, payload: encryptedData)
        
        var data = Data()
        data.append(contentsOf: package.fullPackage)
        return data
    }
}
