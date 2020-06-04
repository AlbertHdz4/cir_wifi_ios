//
//  BeaconModel.swift
//  cir_wireless
//
//  Created by softel on 04/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import Foundation
import CoreBluetooth

public class BeaconModel {
    var beaconString : String?
    var beaconDescription : String?
    var advertisementServices : Array <UUID>

    init (beaconString: String, advertisementServices: Array <UUID>, beaconDescription: String) {
        self.beaconString = beaconString
        self.advertisementServices = advertisementServices
        self.beaconDescription = beaconDescription
    }
}
