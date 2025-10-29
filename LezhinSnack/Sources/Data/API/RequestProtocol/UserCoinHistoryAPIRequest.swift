//
//  UserAPIReqeust.swift
//  LezhinSnack
//
//  Created by 신진우 on 6/3/25.
//

import Alamofire
import Foundation


// 충전 내역 (필터: ALL | EXPIRING)
enum CoinChargeFilter: String { case ALL, EXPIRING }

struct MyCoinChargesAPIRequest: ApiRequestProtocol {
    let page: Int
    let size: Int
    let filter: CoinChargeFilter

    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.myCoinCharges.url }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? {
        AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true)
    }
    var parameters: Parameters? {
        ["page": page,"size": size,"filter": filter.rawValue]
    }
    
    var encoding: ParameterEncoding { URLEncoding.default }
}

// 사용 내역
struct CoinUsageHistoryAPIRequest: ApiRequestProtocol {
    let page: Int
    let size: Int

    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.coinUsageHistory.url }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? {
        AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true)
    }
    var parameters: Parameters? {
        ["page": page,"size": size]
    }
    var encoding: ParameterEncoding { URLEncoding.default }
}

struct UserCoinAPIRequest: ApiRequestProtocol {
    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog ? true : false }
    var url: String { APIEndpoint.myCoins.url }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? { AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true) } // 필요에 따라 헤더 추가
    var parameters: Parameters? { nil }
    var encoding: ParameterEncoding { URLEncoding.default }
}


// 결제 내역(페이징)
struct UserPaymentHistoryAPIRequest: ApiRequestProtocol {
    let page: Int
    let size: Int

    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String {APIEndpoint.userPaymentHistory.url }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? { AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true) }
    var parameters: Parameters? {
        ["page": page,"size": size]
    }
    var encoding: ParameterEncoding { URLEncoding.default }
}

// 결제 상세
struct PaymentDetailAPIRequest: ApiRequestProtocol {
    let transactionId: String

    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.paymentDetail(transactionId: transactionId) }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? {
        AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true)
    }
    var parameters: Parameters? { nil }
    var encoding: ParameterEncoding { URLEncoding.default }
}
