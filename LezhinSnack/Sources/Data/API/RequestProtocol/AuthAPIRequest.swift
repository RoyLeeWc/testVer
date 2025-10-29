//
//  LoginAPIService.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/8/25.
//


import Alamofire
import Combine
import SwiftyUserDefaults


// 로그인 API
struct AuthLoginAPIRequest: ApiRequestProtocol {
    let provider: AuthProvider
    let body: Parameters

    var isUseAccessToken: Bool { false }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.authLogin(provider) }
    var method: HTTPMethod { .post }
    var headers: HTTPHeaders? { AppContext.shared.makeSnackHeaders() } // Authorization 없음
    var parameters: Parameters? { body }   // 🔹 JSON 바디
    var encoding: ParameterEncoding { JSONEncoding.default }
}

// 회원가입 API
struct AuthJoinAPIRequest: ApiRequestProtocol {
    let provider: AuthProvider
    let body: Parameters

    var isUseAccessToken: Bool { false }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.authJoin(provider) }
    var method: HTTPMethod { .post }
    var headers: HTTPHeaders? { AppContext.shared.makeSnackHeaders() }
    var parameters: Parameters? { body }
    var encoding: ParameterEncoding { JSONEncoding.default }
}

// 게스트모드 회원가입 API
struct GuestModeJoinAPIRequest: ApiRequestProtocol {
    let provider: AuthProvider
    let body: Parameters

    var isUseAccessToken: Bool { false }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.guestModeJoin(provider) }
    var method: HTTPMethod { .post }
    var headers: HTTPHeaders? { AppContext.shared.makeSnackHeaders() }
    var parameters: Parameters? { body }
    var encoding: ParameterEncoding { JSONEncoding.default }
}

struct AuthLogoutAPIRequest: ApiRequestProtocol {
    let refreshToken: String
    var isUseAccessToken: Bool { true } // Bearer 사용
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.snackLogout.url }         
    var method: HTTPMethod { .put }
    var headers: HTTPHeaders? { AppContext.shared.makeFullSnackHeaders() }
    var parameters: Parameters? { ["refreshToken": refreshToken] }
    var encoding: ParameterEncoding { JSONEncoding.default }
}
    
// 엑세스토큰 리프레시
struct RefreshTokenAPIRequest: ApiRequestProtocol {
    var isUseAccessToken: Bool { false }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog ? true : false }
    var url: String { APIEndpoint.refreshAccessToken.url }
    var method: HTTPMethod { .post }
    var headers: HTTPHeaders? { AppContext.shared.makeSnackAuthHeaders(includeUserId: true,includeBearer: false) }//AppContext.shared.makeFullSnackHeaders() }
    var parameters: Parameters? { _parameters }
    var encoding: ParameterEncoding { JSONEncoding.default }
    
    private let _parameters: Parameters?
    
    init(parameters: Parameters?) {
        _parameters = parameters
    }
}


///====================================================================================================================================

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
