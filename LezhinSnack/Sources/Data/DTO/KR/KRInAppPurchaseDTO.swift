//
//  InAppPurchaseModel.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/20/25.
//

import Foundation

// MARK: - ChargeResultModel

struct KRInAppPurchaseDTO: Codable {
    var result: String?
    var data: InAppPurchaseResultDTO?

    func isSuccess() -> Bool {
        return result == "SUCCESS"
    }
}

// MARK: - ResultModel

struct InAppPurchaseResultDTO: Codable {
    var userId: Int64?
    var redirectUrl: String?
    var amount: Double?
    var currency: String?
    var tradeId: String?
    var tradeSeq: String?
    var paymentProviderName: String?
    var transactionId: String?
    var paymentMenu: String?
    var chargeCoin: Int?
    var chargeBonusCoin: Int?
    var chargeFreeCoin: Int?
    var chargeMileage: Int32?
    var coinExpiredAt: Int64?
    var bonusCoinExpiredAt: Int64?
    var mileageExpiredAt: Int64?
    var serviceId: String?
    var result: String?

    mutating func setResult(resultVO: String) {
        result = resultVO
    }

    enum CodingKeys: String, CodingKey {
        case userId
        case redirectUrl
        case amount
        case currency
        case tradeId
        case tradeSeq
        case paymentProviderName
        case transactionId
        case paymentMenu
        case chargeCoin
        case chargeBonusCoin
        case chargeMileage
        case coinExpiredAt
        case bonusCoinExpiredAt
        case mileageExpiredAt
        case serviceId
        case result
        case chargeFreeCoin
    }
}

// MARK: - PaymentInfoModel

struct PaymentInfoDTO: Codable {
    var paymentId: String?
    var coinProductId: String?
    var episodeId: String?
    var purchaseType: String?
    var paymentMenu: String?
    var redirectUrl: String?
    var serviceId: String?
    var accessToken: String
    var platform: String?

    enum CodingKeys: String, CodingKey {
        case paymentId
        case coinProductId
        case episodeId
        case purchaseType
        case paymentMenu
        case redirectUrl
        case serviceId
        case accessToken
        case platform
    }
}

// MARK: - PurchaseInquiryModel

struct PurchaseInquiryDTO: Codable {
    var result: String?
    var data: InquiryResultDTO?

    func isSuccess() -> Bool {
        return result == "SUCCESS"
    }
}

// MARK: - InquiryModel

struct InquiryResultDTO: Codable {
    var status: String?
    var etc: String?
    var transactionId: String?

    func isComplete() -> Bool {
        return status == "COMPLETE"
    }

    enum CodingKeys: String, CodingKey {
        case status
        case etc
        case transactionId = "transactionId"
    }
}

// MARK: - PaymentReadyModel

struct PaymentReserveDTO: Codable {
    var result: String?
    var data: PaymentReserveResultDTO?

    func isResult() -> Bool {
        return result == "SUCCESS"
    }
}

// MARK: - PaymentModel

struct PaymentReserveResultDTO: Codable {
    var tradeId: String?
    var productId: Int?
    var productName: String?
    var productCode: String?
    var amount: Double?
    var userId: Int?
    var userEmail: String?
    var currency: String?
    var paymentProviderName: String?
    var paymentProviderMethod: String?
    var paymentProviderMethodCode: String?

    enum CodingKeys: String, CodingKey {
        case tradeId
        case productId
        case productName
        case productCode
        case amount
        case userId
        case userEmail
        case currency
        case paymentProviderName
        case paymentProviderMethod
        case paymentProviderMethodCode
    }
}
