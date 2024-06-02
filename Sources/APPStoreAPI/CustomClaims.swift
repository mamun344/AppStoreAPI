//
//  CustomClaims.swift
//  Mamun
//
//  Created by Mamun on 27/5/24.
//  Copyright © 2023 Mamun. All rights reserved.

import Foundation
import SwiftJWT


struct CustomClaims: Claims {
    let iss: String
    let iat: Date
    let exp: Date
    let aud: [String]
    let bid: String
}
