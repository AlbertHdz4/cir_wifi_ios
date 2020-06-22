//
//  CryptoUtils.swift
//  cir_wireless
//
//  Created by softel on 22/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import Foundation


/**
 * Utilidad de encriptación, desencriptación y cálculo de CRC de paquetes de datos
 */
class CryptoUtils {

    
    /**
     *  Cálculo de CRC 16 para DataLogger
     */
    static func crc16(buffer: [UInt8]) -> UInt16 {
        var crc: UInt16 = 0
        
        for byte in buffer {
            
            crc = UInt16(truncatingIfNeeded: crc >> 8) | (crc << 8) & 0xFFFF
            let byte16 = UInt16(byte)
            crc ^= (byte16 & 0x00FF)  //XOR
            crc ^= ((crc & 0x00FF) >> 4)
            crc ^= ((crc << 12) & 0xFFFF)
            crc ^= (((crc & 0x00FF) << 5) & 0xFFFF)
        }
        return crc
    }
    
    
    /**
     * Encriptación de datos para DataLogger
     */
    static func encryptData(/*encSecDataStruct: Enc_Sec_Data_t = ENC_SEC_DATA_T,*/reverseMac: [UInt8], data: [UInt8]) -> [UInt8] {
        
        let macStruct = (UInt8(reverseMac[0]), UInt8(reverseMac[1]), UInt8(reverseMac[2]),
                         UInt8(reverseMac[3]), UInt8(reverseMac[4]), UInt8(reverseMac[5]))
        
        var myStruct = Enc_Sec_Data_t(inKey: KEY,
                                      inDiv: macStruct,
                                      inDivSz: 6,
                                      kDivRounds: (6 * 16),
                                      kDataRounds: 12)
        
        //var myStruct = encSecDataStruct
        var ioData   = data
        var vDivKey  = [UInt8](repeating: 0, count: 32)
        let size     = UInt8 (ioData.count)
        
        diversify_key(&myStruct, &vDivKey, size)
        encryptCpp(&myStruct, &ioData, size, &vDivKey)
        
        return ioData
    }
    
    
    /**
     * Desencriptación de datos para DataLogger
     */
    static func decryptData(encSecDataStruct: Enc_Sec_Data_t = ENC_SEC_DATA_T, data: [UInt8]) -> [UInt8] {
        var myStruct = encSecDataStruct
        var ioData   = data
        var vDivKey  = [UInt8](repeating: 0, count: 32)
        let size     = UInt8 (ioData.count)
        
        diversify_key(&myStruct, &vDivKey, size)
        decryptCpp(&myStruct, &ioData, size, &vDivKey)
        
        return ioData
    }
    
}
