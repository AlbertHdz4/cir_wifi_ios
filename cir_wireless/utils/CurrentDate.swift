//
//  CurrentDate.swift
//  cir_wireless
//
//  Created by softel on 22/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import Foundation


// Estructura de la fecha para mandarla a la CIR ---------------------
struct DateHour {
    
    var seconds : Int?
    var hour    : Int?
    var day     : Int?
    var month   : Int?
    var year    : Int?
    
    
    init (seconds: Int?, hour: Int?, day: Int?, month: Int?, year: Int?) {
        self.seconds    = seconds
        self.hour       = hour
        self.day        = day
        self.month      = month
        self.year       = year
    }
        
    
    func getDatePackage () -> [Int] {
        return [self.seconds!, self.hour!, self.day!, self.month!, self.year!]
    }
}
// --------------------------------------------------------------------
