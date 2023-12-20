//
//  File.swift
//  cir_wireless
//
//  Created by Softel S.A. de C.V. on 14/12/23.
//  Copyright © 2023 SOFTEL. All rights reserved.
//

import Foundation


struct ApiFirmwaresConstants {
    
    // BASE URL's
    static let BASE_URL_DEV          = "https://applications-softel-dev.wl.r.appspot.com/api/v1/"     //Url Dev
    static let BASE_URL_PROD         = "https://applications-softel.uc.r.appspot.com/api/v1/"     //Url Prod
    static let LOGIN_URL             = "auth/login"
    static let FIRMWARE_URL          = "applications/"
    
    // API Credentials
    static let USR_FW_API                  = "wifiios@softel.mx"
    static let ENCRYPTED_PASS_DEV_FW_API   = "bWt/WDi1D9+qNeIEBtlxBlhMTBoRa/+g3xgjfVT8jjBxPIJjo1nRz8JdGQ=="
    static let ENCRYPTED_PASS_PROD_FW_API  = "JTRTUTs3td7AkqO64LwZrgnASQrHfpZcTJKEz/CQ98u4/U/P4fanVs0aiw=="
    static let SECRET_KEY                  = "S0ft3l==12BoP/cunR1aStyz="
    
}
