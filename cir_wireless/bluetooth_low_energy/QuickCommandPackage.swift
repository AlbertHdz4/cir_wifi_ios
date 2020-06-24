//
//  BleCommands.swift
//  cir_wireless
//
//  Created by softel on 02/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import Foundation


struct QuickCommandPackage {
    
    // Default password
    let _PASSWORD       : [UInt8] = [0x4a, 0xb0, 0x0d, 0xc6, 0xfc, 0x4e,
                              0x3e, 0x8c, 0xf6, 0x1a, 0x5a, 0xcb,
                              0x94, 0xe6, 0x53, 0x15]
    

    var commandLenght   : UInt8?
    var quickCommand    : QuickCommands?
    var payload         : [UInt8]?
    
    
    init(commandLenght: UInt8, quickCommand: QuickCommands, payload: [UInt8]? = nil) {
        self.commandLenght  = commandLenght
        self.quickCommand   = quickCommand
        self.payload        = payload
    }
    
    
    func getQuickCommandPackage () -> [UInt8] {
        var quickCommandPackage = insertArray(toModify: [self.commandLenght!, self.quickCommand!.rawValue], toInsert: self._PASSWORD)
        
        if let _ = payload {
            quickCommandPackage = insertArray(toModify: quickCommandPackage, toInsert: payload!)
        }
        
        return quickCommandPackage
    }
    
    
    private func insertArray (toModify: [UInt8], toInsert: [UInt8]) -> [UInt8] {
        
        var modifiedArray = toModify
        
        for element in toInsert {
            modifiedArray.append(element)
        }
        
        return modifiedArray
    }
}


// Longitudes de los comandos mas comunes ---------------------------
enum QuickCommandsLenghts: UInt8 {
    
    case _COMMAND_WITHOUT_PAYLOAD = 0x12
    
}
// ------------------------------------------------------------------

// Estos comandos y su uso detallado estan en el documento:
// 'Servicio QUICK CMDS BLE CIR Wireless v3.4.7' ---------------------------
enum QuickCommands: UInt8 {
    
    case _OPEN_LOCK                                 = 0x0F
    
    case _CLOSE_LOCK                                = 0x0E
    
    case _SET_DATE                                  = 0x29
    
    case _READ_DATE                                 = 0x32
    
    case _REINIT_EXIT_REACTIVATION_TIME             = 0x2B
    
    case _MAINTENANCE                               = 0x17
    
    case _RELOAD                                    = 0x19
    
    case _ENABLE_PRODUCTION_TEST                    = 0x4E
    
    case _READ_FLAGS_OF_PRODUCTION_TEST             = 0x3D
    
    case _UNLOCK_CIR_DUE_TO_TEST_PRODUCTION_FAILED  = 0x52
    
}
// -------------------------------------------------------------------------


// Para parsear la respuesta de la CIR Wireless ----------------------------
struct QuickCommandResponse {
    
    var length      : UInt64?
    var response    : UInt8?
    var payload     : [UInt8]?
    var fullPackage : [UInt8]?
    
    
    init (responsePackage: [UInt8]?) {
        
        self.fullPackage    = responsePackage
        self.length         = toInt64(bytes: [responsePackage![0]])
        self.response       = responsePackage?[1]
        self.payload        = Array(responsePackage?[2..<responsePackage!.count] ?? [])
        
    }
    
    
    private func toInt64 (bytes: [UInt8]) -> UInt64 {
        precondition(bytes.count <= MemoryLayout<Self>.size)

        var value: UInt64 = 0

        for byte in bytes {
            value <<= 8
            value |= UInt64(byte)
        }
        
        return value
    }
    
    
    func isValid () -> Bool {
        return response != QuickCommandReponses._BAD_RESPONSE.rawValue
    }
}
// ----------------------------------------------------------------------------


// Posibles respuestas de la CIR Wireless -------------------------------------
enum QuickCommandReponses: UInt8 {
    
    case _BAD_RESPONSE                                          = 0x00
    
    case _GOOD_RESPONSE                                         = 0x01
    
    case _LOCK_DISABLED                                         = 0x1E
    
    case _PRODUCTION_TEST_ALREADY_SUCCESSFULLY_COMPLETED        = 0x4F
    
    case _PRODUCTION_TEST_ALREADY_ENABLED_CURRENTLY_RUNNING     = 0x51
    
}
// -----------------------------------------------------------------------------
