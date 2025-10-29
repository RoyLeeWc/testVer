//
//  LoginAPIService.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/8/25.
//


import Alamofire
import Combine



// 게스트모드 로그인 API
struct GuestModeLoginAPIRequest: ApiRequestProtocol {
    var isUseAccessToken: Bool { false }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog ? true : false }
    var url: String { APIEndpoint.guestModeLogin.url }
    var method: HTTPMethod { .post }
    var headers: HTTPHeaders? { AppContext.shared.commonHeader } // 필요에 따라 헤더 추가
    var parameters: Parameters? { _parameters }
    var encoding: ParameterEncoding { JSONEncoding.default }
    
    private let _parameters: Parameters?
    
    init(parameters: Parameters?) {
        _parameters = parameters
    }
}

//SNS 회원가입 API
struct SnsLoginAPIRequest: ApiRequestProtocol {
    var isUseAccessToken: Bool { false }
    var isPrintLog: Bool { true } //AppContext.shared.isPrintAllApiLog ? true : false }
    var url: String { APIEndpoint.snsLogin.url }
    var method: HTTPMethod { .post }
    var headers: HTTPHeaders? { AppContext.shared.commonHeader } // 필요에 따라 헤더 추가
    var parameters: Parameters? { _parameters }
    var encoding: ParameterEncoding { JSONEncoding.default }
    
    private let _parameters: Parameters?
    
    init(parameters: Parameters?) {
        _parameters = parameters
    }
}

//SNS 로그인 API
struct SnsSignUpAPIRequest: ApiRequestProtocol {
    var isUseAccessToken: Bool { false }
    var isPrintLog: Bool { true } //AppContext.shared.isPrintAllApiLog ? true : false }
    var url: String { APIEndpoint.snsSignUp.url }
    var method: HTTPMethod { .post }
    var headers: HTTPHeaders? { AppContext.shared.commonHeader } // 필요에 따라 헤더 추가
    var parameters: Parameters? { _parameters }
    var encoding: ParameterEncoding { JSONEncoding.default }
    
    private let _parameters: Parameters?
    
    init(parameters: Parameters?) {
        _parameters = parameters
    }
}

// 로그아웃 API
struct LogoutAPIRequest: ApiRequestProtocol {
    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog ? true : false }
    var url: String { APIEndpoint.logout.url }
    var method: HTTPMethod { .put }
    var headers: HTTPHeaders? {
        AppContext.shared.makeHeaderWithAccessToken()
    } // 필요에 따라 헤더 추가
    
    var parameters: Parameters? { _parameters }
    var encoding: ParameterEncoding { JSONEncoding.default }
    
    private let _parameters: Parameters?
    
    init(parameters: Parameters?) {
        _parameters = parameters
    }
}

// 엑세스토큰 리프레시
struct RefreshTokenAPIRequest: ApiRequestProtocol {
    var isUseAccessToken: Bool { false }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog ? true : false }
    var url: String { APIEndpoint.refreshAccessToken.url }
    var method: HTTPMethod { .post }
    var headers: HTTPHeaders? { AppContext.shared.commonHeader }
    var parameters: Parameters? { _parameters }
    var encoding: ParameterEncoding { JSONEncoding.default }
    
    private let _parameters: Parameters?
    
    init(parameters: Parameters?) {
        _parameters = parameters
    }
}
