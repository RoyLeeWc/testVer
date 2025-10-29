//
//  AppPaymentReserveEntity.swift
//  LezhinSnack
//
//  Created by lwc on 10/22/25.
//

struct AppPaymentReserveEntity: Hashable {
    let tradeId: String
    let productId: Int
    let productLanguageId: Int
    let productName: String
    let productCode: String
    let amount: Double
    let userId: Int
    let currencyType: String
    let paymentMenuType: String
    let paymentProviderName: String
    let paymentProviderMethod: String
    let redirectUrl: String?
}
