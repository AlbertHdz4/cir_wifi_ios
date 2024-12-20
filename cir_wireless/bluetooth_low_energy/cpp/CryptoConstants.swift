//
//  CryptoConstants.swift
//  cir_wireless
//
//  Created by softel on 22/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import Foundation

// Datos para encriptación de paquetes ---------
let KEY = (UInt8(0x2B), UInt8(0x72), UInt8(0x4A), UInt8(0x2F),
           UInt8(0x48), UInt8(0x6c), UInt8(0x47), UInt8(0x56),
           UInt8(0x5A), UInt8(0x72), UInt8(0x76), UInt8(0x7A),
           UInt8(0x6D), UInt8(0x2A), UInt8(0x40), UInt8(0x24))  // LLAVE DE ENCRIPTACIÓN

var MAC = (UInt8(0x9C), UInt8(0x01), UInt8(0x9B),
           UInt8(0xC5), UInt8(0x1B), UInt8(0x00))               // MAC Y ESTRUCTURA PARA TESTEO
     

var ENC_SEC_DATA_T = Enc_Sec_Data_t(inKey: KEY,
                                    inDiv: MAC,
                                    inDivSz: 6,
                                    kDivRounds: (6 * 16),
                                    kDataRounds: 12)

// ------------------------------------------------
