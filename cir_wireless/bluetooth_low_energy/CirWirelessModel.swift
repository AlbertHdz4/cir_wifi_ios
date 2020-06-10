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

    init (peripheral: CBPeripheral, peripheralId: UUID, beacon: BeaconModel) {
        self.peripheral = peripheral
        self.beacon = beacon
        self.peripheralId = peripheralId
    }
}


enum CirWirelessState: String {
    case cirUnlock = "Cir Wireless is unlocked"
    case cirWireless = "Cir Wireless is locked"
}
