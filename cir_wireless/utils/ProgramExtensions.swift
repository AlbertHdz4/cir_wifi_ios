//
//  ProgramExtensions.swift
//  cir_wireless
//
//  Created by softel on 11/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import Foundation


// Extensiones
extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}
