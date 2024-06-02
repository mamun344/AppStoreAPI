//
//  TransactionClaims.swift
//  Mamun
//
//  Created by Mamun on 27/5/24.
//  Copyright © 2023 Mamun. All rights reserved.

import Foundation
import SwiftJWT


public struct TransactionClaims: Claims {
    public let transactionId: String?
    public let originalTransactionId: String?
    public let bundleId: String?
    public let productId: String?
    public let purchaseDate: Double?
    public let originalPurchaseDate: Double?
    public let quantity: Int?
    public let type: String?
    public let inAppOwnershipType: String?
    public let signedDate: Double?
    public let environment: String?
    public let transactionReason: String?
    public let storefront: String?
    public let storefrontId: String?
    public let price: Double?
    public let currency: String?
}
