//
//  AppStoreAPI.swift
//  Mamun
//
//  Created by Mamun on 27/5/24.
//  Copyright © 2023 Mamun. All rights reserved.

import Foundation
import SwiftJWT


public class AppStoreAPI {
    
    let isSandbox: Bool
    
    init(isSandbox: Bool) {
        self.isSandbox = isSandbox
    }
    
    func requestForTransaction(devInfo: AppDevInfo, userOrderId: String, onDone: @escaping ((_ transactions: [TransactionClaims]?, _ error: String?)->())) {
        
        let tokenInfo = getJWTToken(info: devInfo)
        
        if let token = tokenInfo.0 {
            let api = API()
            
            let url = isSandbox ?
            "https://api.storekit-sandbox.itunes.apple.com/inApps/v1/lookup/" :
            "https://api.storekit.itunes.apple.com/inApps/v1/lookup/"
            
            api.request(url + userOrderId, headers: ["Authorization": "Bearer " + token]) { data, code, success in
                
                print("HTTP status:", code)
                
                if let data, let json = api.jsonFrom(data: data) as? [String: Any] {
                    if let status = json["status"] as? Int {
                        print("Status", status)
                    }
                    
                    if let transactions = json["signedTransactions"] as? [String], transactions.count > 0 {
                        var infos = [TransactionClaims]()
                        
                        transactions.forEach {
                            let newJWT = try? JWT<TransactionClaims>.init(jwtString: $0)
                            
                            if let claims = newJWT?.claims {
                                infos.append(claims)
                            }
                        }
                        
                        onDone(infos, nil)
                    }
                    else {
                        onDone(nil, "No transaction found")
                    }
                }
                else {
                    onDone(nil, "No data found. Https status: \(code)")
                }
            }
        }
        else {
            onDone(nil, tokenInfo.1)
        }
    }
    
    
    private func getJWTToken(info: AppDevInfo)->(String?, String?) {
        let header = Header.init(typ: "JWT", kid: info.apiKeyID)
        
        
        guard let keyData = info.privateKey.data(using: .utf8) else {
            return (nil, "Invalid private key")
        }
        
        let claims = CustomClaims(iss: info.issuerID,
                                  iat: Date(),
                                  exp: Date().addingTimeInterval(5.0 * 60.0),
                                  aud: ["appstoreconnect-v1"],
                                  bid: info.bundleID)
        
        
        var jwt = JWT(header: header, claims: claims)
        let jwtSigner = JWTSigner.es256(privateKey: keyData)
        
        
        guard let jwtToken = try? jwt.sign(using: jwtSigner) else {
            return (nil, "Failed to sign")
        }
        
        debugPrint("JWTToken: " + jwtToken)
        return (jwtToken, nil)
    }
}
