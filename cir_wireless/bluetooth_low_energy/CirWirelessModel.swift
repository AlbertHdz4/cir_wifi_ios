//
//  CirWireless.swift
//  cir_wireless
//
//  Created by softel on 04/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//


import Foundation
import CoreBluetooth


class CirWirelessModel {
    
    var peripheral : CBPeripheral?
    var peripheralId : UUID?
    var beacon: BeaconModel? // Primer beacon, almacena todo el payload del dispositivo
    var iBeacon: BeaconModel? // Segundo beacon estructurado como iBeacon
    var cirWirelessState: CirWirelessState?
    private var cirWirelessMac: String?
    
    
    init (peripheral: CBPeripheral, peripheralId: UUID, beacon: BeaconModel) {
        self.peripheral = peripheral
        self.beacon = beacon
        self.peripheralId = peripheralId
    }
    
    func getCirWirelessMac () -> String {
        
        if cirWirelessMac == nil {
            let macReversed = String(((iBeacon?.advertisementData[BeaconFields.cirWirelessMac.rawValue] as? Data)!.hexDescription).reversed())
            cirWirelessMac = addDotsToMac(macWithoutDots: macReversed)
            
        }
        
        
        return cirWirelessMac!
    }
    
    private func addDotsToMac (macWithoutDots: String) -> String {

        print(macWithoutDots)
        
        let macArray = Array(macWithoutDots)
        let macWithDots = "\(macArray[1])\(macArray[0]):\(macArray[3])\(macArray[2]):" +
                          "\(macArray[5])\(macArray[4]):\(macArray[7])\(macArray[6]):" +
                          "\(macArray[9])\(macArray[8]):\(macArray[11])\(macArray[10])"
        
        return macWithDots.uppercased()
    }
}


enum CirWirelessState: String {
    case cirUnlock = "Cir Wireless is unlocked"
    
    case cirWireless = "Cir Wireless is locked"
}


enum BeaconFields: String {
    case cirWirelessMac = "kCBAdvDataLeBluetoothDeviceAddress"
}
