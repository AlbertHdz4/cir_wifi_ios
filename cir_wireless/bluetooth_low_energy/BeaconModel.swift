//
//  BeaconModel.swift
//  cir_wireless
//
//  Created by softel on 04/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import Foundation
import CoreBluetooth

class BeaconModel {
    
    // Beacon's variables
    var rssi                : integer_t?
    var beaconPayload       : Data?
    var beaconString        : String?
    var listOfUuidServices  : Array <UUID>?
    var advertisementData   : [String : Any]


    init (rssi: integer_t, beaconPayload: Data, advertisementData: [String : Any]) {
        
        self.rssi               = rssi
        self.beaconPayload      = beaconPayload
        self.advertisementData  = advertisementData
        self.beaconString       = (advertisementData[CBAdvertisementDataManufacturerDataKey] as! Data).hexDescription
        self.listOfUuidServices = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? Array<UUID> ?? []
        
    }
}


enum BeaconError: String {
    
    case beaconErrorCast = "Error beacon cast, see beacon value"
    
}

