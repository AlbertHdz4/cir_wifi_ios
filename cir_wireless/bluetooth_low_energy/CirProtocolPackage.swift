//
//  CirProtocolPackage.swift
//  cir_wireless
//
//  Created by softel on 24/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import Foundation


struct CirProtocolPackage {
    
    var preambulo           : UInt8!
    var destino             : UInt8!
    var origen              : UInt8!
    var packageLength       : UInt8!
    var command             : UInt8!
    var payload             : [UInt8]?
    var crcMSB              : UInt8!
    var crcLSB              : UInt8!
    
    
    init(preambulo: UInt8, destino: UInt8, origen: UInt8,
         packageLength: UInt8, command: UInt8, payload: [UInt8]?,
         crcMSB: UInt8, crcLSB: UInt8) {
        
        self.preambulo      = preambulo
        self.destino        = destino
        self.origen         = origen
        self.packageLength  = packageLength
        self.command        = command
        self.payload        = payload
        self.crcMSB         = crcMSB
        self.crcLSB         = crcLSB
        
    }
    
    
}


enum CirProtocolHeader      : UInt8 {
    
    case _PREAMBULO         = 0x55
    
    case _DESTINO           = 0x10
    
    case _ORIGEN            = 0x13

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
}


struct CirProtocolResponse {
    
    var preambulo           : UInt8!
    var destino             : UInt8!
    var origen              : UInt8!
    var packageLenth        : UInt8!
    var payload             : [UInt8]?
    var crcMSB              : UInt8!
    var crcLSB              : UInt8!
    
    
    
}


enum CirProtocolResponses   : UInt8 {
    case _POLEO_PACKAGE     = 0x0a
}
