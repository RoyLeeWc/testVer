//
//  UserAPIReqeust.swift
//  LezhinSnack
//
//  Created by 신진우 on 6/3/25.
//

import Alamofire


struct UserCoinAPIRequest: ApiRequestProtocol {
    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog ? true : false }
    var url: String { APIEndpoint.userCoinBalance.url }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? { AppContext.shared.makeHeaderWithAccessToken() } // 필요에 따라 헤더 추가
    var parameters: Parameters? { _parameters }
    var encoding: ParameterEncoding { URLEncoding.default }
    
    private let _parameters: Parameters?
    
    init(parameters: Parameters?) {
        _parameters = parameters
    }
    
}

