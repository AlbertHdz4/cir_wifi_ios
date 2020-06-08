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
    
    // Beacon's variables
    var rssi: integer_t?
    var beacon: Data?
    var beaconString: String?
    var listOfUuidServices: Array <UUID>?
    var advertisementData: [String : Any]


    init (rssi: integer_t, beacon: Data, advertisementData: [String : Any]) {
        self.rssi = rssi
        self.beacon = beacon
        self.advertisementData = advertisementData
        self.beaconString = advertisementData[CBAdvertisementDataManufacturerDataKey] as? String ?? BeaconError.beaconErrorCast.rawValue
        self.listOfUuidServices = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? Array<UUID> ?? []
    }
}


enum BeaconError: String {
    case beaconErrorCast = "Error beacon cast, see beacon value"
}
