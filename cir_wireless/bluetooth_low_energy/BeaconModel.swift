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
    var beaconVersion       : String?
    var beaconModelName     = "NO AVAILABLE"
    var listOfUuidServices  : Array <UUID>?
    var advertisementData   : [String : Any]


    init (rssi: integer_t, beaconPayload: Data, advertisementData: [String : Any]) {
        self.rssi               = rssi
        self.beaconPayload      = beaconPayload
        self.advertisementData  = advertisementData
        self.beaconString       = (advertisementData[CBAdvertisementDataManufacturerDataKey] as! Data).hexDescription
        self.listOfUuidServices = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? Array<UUID> ?? []
        
        getBeaconModelValues()
    }
    
    
    private func getBeaconModelValues () {
        if (beaconString != nil) {
            beaconVersion   = beaconString?[0..<4]
            beaconModelName = getBeaconModelName(beaconVersion: beaconVersion)
        }
    }
    
    
    private func getBeaconModelName (beaconVersion: String?) -> String {
        switch beaconVersion {
        case "000b":
            return "CIR Wireless"
        
        case "000c":
            return "CIR Wireless"
            
        case "000d", "0010":
            return "CIR 232"
            
        case "000e", "0011":
            return "CIR 232 blocked"
            
        default:
            return "NO AVAILABLE"
        }
    }
}


enum BeaconError: String {
    
    case beaconErrorCast = "Error beacon cast, see beacon value"
    
}

