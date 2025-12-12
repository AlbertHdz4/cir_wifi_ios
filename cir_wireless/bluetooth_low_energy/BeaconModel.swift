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
//        case "000b":
//            return "CIR Wireless"
//        
//        case "000c":
//            return "CIR Wireless"
//            
//        case "000d", "0010":
//            return "CIR 232"
//            
//        case "000e", "0011":
//            return "CIR 232 blocked"
//            
//        case "001a":
//            return "CIR232_3"
            
        case "0001": return "CIL"
        case "0002": return "CIR NAMA"
        case "0005": return "CIL"
        case "0006": return "CIL"
        case "0007": return "CIL"
        case "0008": return "CIL"
        case "0009": return "CIL"
        case "000B": return "CIRWIFI"
        case "000C": return "CIRWIFI"
        case "000D": return "CIR232"
        case "000E": return "CIR232"
        case "000F": return "CIL2"
        case "0010": return "CIR232 Dual"
        case "0011": return "CIR232 Dual"
        case "0012": return "CIL2"
        case "0013": return "CIR232"
        case "0014": return "CIR232"
        case "0015": return "CIRWIFI_3"
        case "0016": return "CIRWIFI_3"
        case "0017": return "CIR232_3"
        case "0018": return "CIR232_3"
        case "001A": return "CIR232_3"
        case "001B": return "CIR232_3"
        case "001C": return "CIR232_3 Dual"
        case "001D": return "CIR232_3 Dual"
        case "001E": return "CIL2 RS232"
        case "0020": return "CIL3"
        case "0021": return "CIRWIFI"
        case "0022": return "CIRWIFI"
        case "0023": return "CIRWIFI"
        case "0024": return "CIR232_3"
        case "0025": return "CIR232_3"
        case "0026": return "CIR232_3"
        case "0027": return "CIRWIFI_3"
        case "0028": return "CIRWIFI_3"
        case "0029": return "CIRWIFI_3"
        case "002A": return "CIRWIFI_3 Dual"
        case "002B": return "CIRWIFI_3 Dual"
        case "0030": return "CIL3"
        case "0031": return "CIL2"
        case "0032": return "EVO + BLE"
        case "0033": return "CIL3"
        case "0034": return "CIR232_3 LTE"
        case "0035": return "CIR232_3 LTE"
            
        default:
            return "NO AVAILABLE"
        }
    }
}


enum BeaconError: String {
    
    case beaconErrorCast = "Error beacon cast, see beacon value"
    
}

