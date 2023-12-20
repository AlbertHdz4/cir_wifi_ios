//
//  Encrypt.swift
//  cir_wireless
//
//  Created by Softel S.A. de C.V. on 14/12/23.
//  Copyright © 2023 SOFTEL. All rights reserved.
//

import Foundation

import CryptoKit


func encrypt(password: String, key: String) throws -> String {
    // Convierte la clave a un formato adecuado
    let keyData = Data(key.utf8).prefix(16)

    // Convierte la contraseña a un formato adecuado
    let passwordData = Data(password.utf8)

    // Crea un objeto AES.GCM.SealedBox para almacenar la contraseña cifrada
    let sealedBox = try AES.GCM.seal(passwordData, using: SymmetricKey(data: keyData))

    // Convierte el objeto SealedBox a una cadena Base64 para almacenamiento
    return sealedBox.combined!.base64EncodedString()
}

func decrypt(encryptedPassword: String, key: String) throws -> String {
    // Convierte la clave a un formato adecuado
    let keyData = Data(key.utf8).prefix(16)

    // Convierte la contraseña cifrada de Base64 a un objeto SealedBox
    let sealedBox = try AES.GCM.SealedBox(combined: Data(base64Encoded: encryptedPassword)!)

    // Desencripta la contraseña
    let decryptedData = try AES.GCM.open(sealedBox, using: SymmetricKey(data: keyData))

    // Convierte la contraseña desencriptada a una cadena
    return String(data: decryptedData, encoding: .utf8)!
}
