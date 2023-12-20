//
//  CurrentDate.swift
//  cir_wireless
//
//  Created by softel on 22/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import Foundation


class DatePackage {
    
    public static func getDatePackage () -> DateHour {
        let date        = Date()
        let calendar    = Calendar.current
        let yearStr     = String(calendar.component(.year, from: date))
        let month       = calendar.component(.month, from: date)
        let dayOfMonth  = calendar.component(.day, from: date)
        let dayOfWeek   = calendar.component(.weekday, from: date)
        let hour        = calendar.component(.hour, from: date)
        let minutes     = calendar.component(.minute, from: date)
        let seconds     = calendar.component(.second, from: date)

        let year = UInt8(yearStr.suffix(2))
        
        return DateHour(seconds     : UInt8(seconds),
                        minutes     : UInt8(minutes),
                        hour        : UInt8(hour),
                        dayOfWeek   : UInt8(dayOfWeek - 1),
                        dayOfMonth  : UInt8(dayOfMonth),
                        month       : UInt8(month),
                        year        : year!)
    }
}


// Estructura de la fecha para mandarla a la CIR ---------------------
struct DateHour {
    
    var seconds         : UInt8!
    var minutes         : UInt8!
    var hour            : UInt8!
    var dayOfWeek       : UInt8!
    var dayOfMonth      : UInt8!
    var month           : UInt8!
    var year            : UInt8!
    var fullPackage     : [UInt8]!
    
    
    init (seconds: UInt8, minutes: UInt8, hour: UInt8, dayOfWeek: UInt8, dayOfMonth: UInt8, month: UInt8, year: UInt8) {
        self.seconds        = seconds
        self.minutes        = minutes
        self.hour           = hour
        self.dayOfWeek      = dayOfWeek
        self.dayOfMonth     = dayOfMonth
        self.month          = month
        self.year           = year
        self.fullPackage    = getDatePackage()
    }
        
    
    func getDatePackage () -> [UInt8] {
        return [self.seconds, self.minutes, self.hour, self.dayOfMonth, self.dayOfWeek, self.month, self.year]
    }
}
// --------------------------------------------------------------------
