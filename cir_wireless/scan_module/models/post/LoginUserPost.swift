//
//  LoginUserPost.swift
//  cir_wireless
//
//  Created by Softel S.A. de C.V. on 19/12/23.
//  Copyright © 2023 SOFTEL. All rights reserved.
//

import Foundation

struct LoginUserPostResponse: Decodable {
    let data                : [String: Data]
    let token               : String
    let expiresIn           : String
    let error               : String
    let email               : String
    let message             : String
    let type                : String
    
    
    enum CodingKeys: String, CodingKey {
        case data               = "data"
        case token              = "token"
        case expiresIn          = "expiresIn"
        case error              = "error"
        case message            = "message"
        case email              = "email"
        case type               = "type"
      }
}
