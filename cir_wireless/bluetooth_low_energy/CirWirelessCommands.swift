//
//  BleCommands.swift
//  cir_wireless
//
//  Created by softel on 02/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import Foundation

// Clase que contiene los comandos usados para la Cir Wireless
class CirWirelessCommands {
    
    init(commandPackage: CommandPackage) {
        print("INITIATE")
    }
    
}


struct CommandPackage {
    
    // Default password
    let PASSWORD = [0x4a, 0xb0, 0x0d, 0xc6, 0xfc, 0x4e,
                    0x3e, 0x8c, 0xf6, 0x1a, 0x5a, 0xcb,
                    0x94, 0xe6, 0x53, 0x15]
    
    
    var commandLenght: UInt8?
    var shortCommand: ShortCommands?
    var payload: Data
    
    
    init(commandLenght: UInt8, shortCommand: ShortCommands, payload: Data? = nil) {
        self.commandLenght = commandLenght
        self.shortCommand = shortCommand
        self.payload = payload!
    }
    
}


enum ShortCommands: UInt8 {
    
    case _OPEN_LOCK = 0x00
}
