//
//  CoinWalletEntities.swift
//  LezhinSnack
//
//  Created by lwc on 10/1/25.
//
import Foundation

enum CoinType: String {
    case COIN, BONUS
    case unknown
}

enum CoinTitleType: String {
    // swiftlint:disable identifier_name
    case ADMIN, BONUS_COIN, COIN, ADMIN_CUSTOM
    // swiftlint:enable identifier_name
    case unknown
}

enum CoinStatusType: String {
    case USE, CHARGE, REFUND, ADJUST
    case unknown
}

struct CoinChargeEntity: Hashable {
    let title: String
    let coinType: CoinType
    let coinTitleType: CoinTitleType
    let initialAmount: Int
    let remainAmount: Int
    let expiredAt: Int64
    let createdAt: Int64
}

// ✅ Hashable 채택
struct CoinUsageEntity: Hashable {
    let title: String
    let coinStatusType: CoinStatusType
    let coin: Int
    let createdAt: Int64
}
