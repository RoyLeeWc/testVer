//
//  AppPaymentReserveDTO.swift
//  LezhinSnack
//
//  Created by lwc on 10/22/25.
//

// AppPaymentReserveDTO.swift
struct AppPaymentReserveDTO: Decodable {
    let responseCode: String
    let data: AppPaymentReserveDataDTO?
    let errorData: ErrorDataDTO?
}

struct AppPaymentReserveDataDTO: Decodable {
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

extension AppPaymentReserveDataDTO {
    func toEntity() -> AppPaymentReserveEntity {
        .init(
            tradeId: tradeId,
            productId: productId,
            productLanguageId: productLanguageId,
            productName: productName,
            productCode: productCode,
            amount: amount,
            userId: userId,
            currencyType: currencyType,
            paymentMenuType: paymentMenuType,
            paymentProviderName: paymentProviderName,
            paymentProviderMethod: paymentProviderMethod,
            redirectUrl: redirectUrl
        )
    }
}
