//
//  CommmonAPIRequest.swift
//  LezhinSnack
//
//  Created by lwc on 9/4/25.
//

import Alamofire



struct AppVersionsCheckAPIRequest: ApiRequestProtocol {
    var isUseAccessToken: Bool { false }
    var isPrintLog: Bool { true }
    var url: String { APIEndpoint.appVersionsCheck.url }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? { AppContext.shared.postManTokenHeader }
    var parameters: Parameters? { _parameters }
    var encoding: ParameterEncoding { URLEncoding.default }
    
    private let _parameters: Parameters?
      
    init(parameters: Parameters?) {
        _parameters = parameters
    }
}
