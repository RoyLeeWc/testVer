//
//  HistoryAPIRequest.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/12/25.
//

import Alamofire

struct CoinChargeHistoryAPIRequest: ApiRequestProtocol {
    var isUseAccessToken: Bool { false }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog ? true : false }
    var url: String { APIEndpoint.coinChargeHistory.url }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? { AppContext.shared.makeHeaderWithAccessToken() } // 필요에 따라 헤더 추가
    var parameters: Parameters? { _parameters }
    var encoding: ParameterEncoding { URLEncoding.default }
    
    private let _parameters: Parameters?
    
    init(parameters: Parameters?) {
        _parameters = parameters
    }
    
}


struct PurchaseHistoryAPIRequest: ApiRequestProtocol {
    var isUseAccessToken: Bool { false }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog ? true : false }
    var url: String { APIEndpoint.purchaseHistory.url }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? { AppContext.shared.makeHeaderWithAccessToken() } // 필요에 따라 헤더 추가
    var parameters: Parameters? { _parameters }
    var encoding: ParameterEncoding { URLEncoding.default }
    
    private let _parameters: Parameters?
    
    init(parameters: Parameters?) {
        _parameters = parameters
    }
    
}
