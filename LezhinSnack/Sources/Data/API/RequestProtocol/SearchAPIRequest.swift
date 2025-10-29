//
//  SearchAPIRequest.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/9/25.
//

import Alamofire


struct SearchAPIRequest: ApiRequestProtocol {
    var isUseAccessToken: Bool { false }
    var isPrintLog: Bool { false }
    var url: String { APIEndpoint.search.url }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? { AppContext.shared.commonHeader } // 필요에 따라 헤더 추가
    var parameters: Parameters? { _parameters }
    var encoding: ParameterEncoding { URLEncoding.default }
    
    private let _parameters: Parameters?
    
    init(parameters: Parameters?) {
        _parameters = parameters
    }
}
