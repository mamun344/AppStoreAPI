//
//  AppDevInfo.swift
//  Mamun
//
//  Created by Mamun on 27/5/24.
//  Copyright © 2023 Mamun. All rights reserved.

import Foundation


public struct AppDevInfo: Codable {
    let bundleID: String
    let issuerID: String
    let apiKeyID: String
    let privateKey: String  // inside .p8 file
    
    
    public init(bundleID: String, issuerID: String, apiKeyID: String, privateKey: String) {
        self.bundleID = bundleID
        self.issuerID = issuerID
        self.apiKeyID = apiKeyID
        self.privateKey = privateKey
    }
}
