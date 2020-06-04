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
    var peripheralId : String?
    var beacon: BeaconModel?
    var cirWirelessState: CirWirelessState?

    init (peripheral: CBPeripheral, peripheralId: String, beacon: BeaconModel) {
        self.peripheral = peripheral
        self.beacon = beacon
        self.peripheralId = peripheralId
    }
}


enum CirWirelessState: String {
    case cirUnlock = "Cir Wireless is unlocked"
    case cirWireless = "Cir Wireless is locked"
}
