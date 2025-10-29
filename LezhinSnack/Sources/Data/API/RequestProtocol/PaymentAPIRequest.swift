//
//  PaymentAPIRequest.swift
//  LezhinSnack
//
//  Created by lwc on 10/22/25.
//

import Alamofire

struct PaymentProvidersAPIRequest: ApiRequestProtocol {
    let paymentMenuType: String  // "COIN_CONVERSION" | "COIN_PRODUCT" | "SUBSCRIPTION_PRODUCT"

    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.paymentProviders.url }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? {
        AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true)
    }
    var parameters: Parameters? { ["paymentMenuType": paymentMenuType] }
    var encoding: ParameterEncoding { URLEncoding.default }
}

struct AppPaymentReserveAPIRequest: ApiRequestProtocol {
    // Body (문서 예시 그대로)
    let accessToken: String
    let countryCode: String
    let ipAddress: String
    let languageType: String
    let paymentMenuType: String          // "COIN_CONVERSION" | "COIN_PRODUCT" | "SUBSCRIPTION_PRODUCT"
    let paymentProviderId: Int
    let productId: Int?                  // 주석 처리된 케이스 있으므로 Optional
    let platform: String                 // "IOS" | "ANDROID" (문서 예시엔 ANDROID도 있음)

    var isUseAccessToken: Bool { true }  // 헤더에도 Bearer 포함
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { "https://dev-flex.lezhinsnack.com/app/payments" } // 절대경로 (별도 FLEX 도메인)
    var method: HTTPMethod { .post }
    var headers: HTTPHeaders? {
        AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true)
    }
    var parameters: Parameters? {
        var param: Parameters = [
            "accessToken": accessToken,
            "countryCode": countryCode,
            "ipAddress": ipAddress,
            "languageType": languageType,
            "paymentMenuType": paymentMenuType,
            "paymentProviderId": paymentProviderId,
            "platform": platform
        ]
        if let productId { param["productId"] = productId }
        return param
    }
    var encoding: ParameterEncoding { JSONEncoding.default }
}


struct IosTransactionAPIRequest: ApiRequestProtocol {
    let tradeId: String
    let transactionId: String
    let environment: String     // "SANDBOX" | "PRODUCTION"
    let isSubscription: Bool?   // 기본 false. 서버 스키마상 optional

    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }

    // FLEX 별도 도메인 — 프로젝트에 baseFlexApiUrl이 있으면 그걸 쓰도록 교체 가능
    var url: String { "https://dev-flex.lezhinsnack.com/app/ios/transaction" }
    var method: HTTPMethod { .post }
    var headers: HTTPHeaders? {
        AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true)
    }
    var parameters: Parameters? {
        var param: Parameters = [
            "tradeId": tradeId,
            "transactionId": transactionId,
            "environment": environment
        ]
        if let isSubscription { param["isSubscription"] = isSubscription }
        return param
    }
    var encoding: ParameterEncoding { JSONEncoding.default }
}

struct CoinProductsAPIRequest: ApiRequestProtocol {
    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.coinProducts.url }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? { AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true) }
    var parameters: Parameters? { nil }
    var encoding: ParameterEncoding { URLEncoding.default }
}
