//
//  TransactionClaims.swift
//  Mamun
//
//  Created by Mamun on 27/5/24.
//  Copyright © 2023 Mamun. All rights reserved.

import Foundation
import SwiftJWT


public struct TransactionClaims: Claims {
    let transactionId: String?
    let originalTransactionId: String?
    let bundleId: String?
    let productId: String?
    let purchaseDate: Double?
    let originalPurchaseDate: Double?
    let quantity: Int?
    let type: String?
    let inAppOwnershipType: String?
    let signedDate: Double?
    let environment: String?
    let transactionReason: String?
    let storefront: String?
    let storefrontId: String?
    let price: Double?
    let currency: String?
}
