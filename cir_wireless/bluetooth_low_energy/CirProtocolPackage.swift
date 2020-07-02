//
//  CirProtocolPackage.swift
//  cir_wireless
//
//  Created by softel on 24/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import Foundation


struct CirProtocolPackage {
    
    var preambulo           : CirProtocolHeader!
    var destino             : CirProtocolHeader!
    var origen              : CirProtocolHeader!
    var packageLength       : UInt8!
    var command             : CirProtocolCommands!
    var payload             : [UInt8]?
    var fullPackage         : [UInt8]!
    
    
    init (preambulo: CirProtocolHeader, destino: CirProtocolHeader, origen: CirProtocolHeader,
          packageLength: UInt8, command: CirProtocolCommands, payload: [UInt8]?) {
        
        self.preambulo      = preambulo
        self.destino        = destino
        self.origen         = origen
        self.packageLength  = packageLength
        self.command        = command
        self.payload        = payload
        self.fullPackage    = formPackage()
    }
    
    
    private func formPackage () -> [UInt8] {
        var package = [UInt8] ()
        
        package.append(preambulo.rawValue)
        package.append(origen.rawValue)
        package.append(destino.rawValue)
        package.append(packageLength)
        package.append(command.rawValue)
        
        if let _ = payload {
            for value in payload! {
                package.append(value)
            }
        }
        
        let crc = CryptoData.crc16(buffer: package).byteArray
         
        package.append(crc[0])
        package.append(crc[1])
         
        return package
    }
}


enum CirProtocolHeader      : UInt8 {
    
    case _PREAMBULO         = 0x55
    
    case _DESTINO           = 0x10
    
    case _ORIGEN            = 0x13

}


enum CirProtocolCommmonLengths  : UInt8 {
    
    case _BASE_PACKAGE_LENGTH   = 0x07

}


enum CirProtocolCommands    : UInt8 {
    
    case _POLEO                 = 0xc5
    
    case _STATUS                = 0xc1
    
    case _READ_DATA_EEPROM      = 0x03
    
    case _WRITE_DATA_EEPROM     = 0x05
    
    case _TESTER_MODE           = 0xff
    
    case _REQUEST_STATUS        = 0x20
    
    case _RESET                 = 0x0c
    
    case _READ_HOUR_AND_DATE    = 0x32
    
    case _SET_HOUR_AND_DATE     = 0x29
    
    case _READ_PRODUCTION_FLAGS = 0x3d
    
    case _CLOSE_LOCK            = 0x0e
    
    case _OPEN_LOCK             = 0x0f
    
    case _MAINTENANCE           = 0x17
    
    case _RELOAD                = 0x19
    
    case _RESET_WIFI_TASK       = 0x47
    
    case _GET_AP_LIST           = 0x49
    
    case _SET_SSID              = 0x21
    
    case _SET_SSID_PASSCODE     = 0x24
    
    case _TEST_WIFI_CONNECTION  = 0x27
    
    case _GENERIC_AT            = 0x4b

    case _READ_AT_RESULT        = 0x34
}


enum ATPrefixes: String {
    
    case _AT_CW_MODE        = "AT+CWMODE="
    
    case _AT_CIP_START      = "AT+CIPSTART=\"TCP\","
    
    case _AT_CW_SAP         = "AT+CWSAP="
    
    case _RESET_WIFI        = "AT+RST"
    
    case _AT_AUTOCONNECT    = "AT+CWAUTOCONN="
    
    case _AT_SEND_CONFIG    = "AT+CWJAP="
}


enum ATModes: Int {
    case _MASTER_SLAVE      = 3
    
    case _SLAVE             = 2
    
    case _NOT_SEND_SSID     = 1
    
    case _SEND_SSID         = 0
}


struct CirProtocolResponse {
    
    var preambulo           : UInt8!
    var destino             : UInt8!
    var origen              : UInt8!
    var packageLength       : UInt8!
    var response            : UInt8!
    var payload             : [UInt8]?
    var crcMSB              : UInt8!
    var crcLSB              : UInt8!
    var fullPackage         : [UInt8]!
    
    
    init (protocolResponse: [UInt8]) {
        self.fullPackage  = protocolResponse
        self.preambulo      = protocolResponse[0]
        self.origen         = protocolResponse[1]
        self.destino        = protocolResponse[2]
        self.packageLength  = protocolResponse[3]
        self.response       = protocolResponse[4]
        self.crcMSB         = protocolResponse[Int(packageLength) - 2]
        self.crcLSB         = protocolResponse[Int(packageLength) - 1]
        self.payload        = getPayload()
    }
    
    
    func isAPoleoPackage () -> Bool {
        return fullPackage[4] == CirProtocolResponses._POLEO_PACKAGE.rawValue
    }
    
    
    func isAStatusPackage () -> Bool {
        return fullPackage[4] == CirProtocolResponses._STATUS_PACKAGE.rawValue
    }
    
    
    func getPayload () -> [UInt8]? {
        
        var payloadPackage = [UInt8] ()
        
        if packageLength > 7 {
            for i in 5..<(packageLength - 2) {
                payloadPackage.append(fullPackage[Int(i)])
            }
        }
        
        return payloadPackage
    }
    
    func decryptPayload (cirWirelessMac: [UInt8]) -> [UInt8] {
        if let _ = payload {
            return CryptoData.decryptData(reverseMac: cirWirelessMac, data: payload!)
        }
        
        print("Payload nil")
        return []
    }
}


enum CirProtocolResponses   : UInt8 {
    case _POLEO_PACKAGE                     = 0xC5
    
    case _STATUS_PACKAGE                    = 0xC1
    
    case _TASK_SUCCESSFULLY_RESET           = 0x48
    
    case _SEEN_ACCESS_POINTS                = 0x4A
    
    case _SSID_SUCCESSFULLY_RECEIVED        = 0x22
    
    case _SSID_BAD_RECEIVED                 = 0x23
    
    case _PASSCODE_SUCCESSFULLY_RECEIVED    = 0x25
    
    case _PASSCODE_BAD_RECEIVED             = 0x26
}


enum ATResponses            : UInt8 {
    case _AT_OK_COMMAND                     = 0x4c
    
    case _AT_ERROR_COMMAND                  = 0x4d
    
    case _AT_COMMAND_READY                  = 0x35
    
    case _AT_COMMAND_NOT_AVAILABLE          = 0x36
}


enum ATResponsesString      : String {
    case _AT_OK         = "OK"
}
