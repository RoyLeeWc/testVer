//
//  IosTransactionEntity.swift
//  LezhinSnack
//
//  Created by lwc on 10/22/25.
//

struct IosTransactionEntity: Hashable {
    let userId: Int
    let redirectUrl: String?
    let amount: Double
    let currencyType: String
    let tradeId: String
    let paymentMenuType: PaymentMenuType
    let paymentProviderName: String
    let transactionId: String
    let platform: String
    let paymentProviderMethod: String
    let paymentStatusType: String
    let chargeCoins: [IosChargeCoinEntity]
}

struct IosChargeCoinEntity: Hashable {
    let coinType: String
    let coinAmount: Int
    let coinExpiredPeriod: Int
}
