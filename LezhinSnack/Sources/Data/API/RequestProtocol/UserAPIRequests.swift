//
//  UserAPIRequests.swift
//  LezhinSnack
//
//  Created by lwc on 9/30/25.
//

import Foundation
import Alamofire

// 유저정보 조회 GET /user
struct UserInfoAPIRequest: ApiRequestProtocol {
    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.userInfo.url }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? { AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true) }                  // 공통 헤더 사용
    var parameters: Parameters? { nil }
    var encoding: ParameterEncoding { URLEncoding.default }
}

// 닉네임 수정 put /user?nickname=...
struct UpdateNicknameAPIRequest: ApiRequestProtocol {
    let nickname: String
    
    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String {
        var comps = URLComponents(string: APIEndpoint.userInfo.url)!
        comps.queryItems = [URLQueryItem(name: "nickname", value: nickname)]
        return comps.url!.absoluteString
    }
    var method: HTTPMethod { .put }
    var headers: HTTPHeaders? { AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true) }
    var parameters: Parameters? { nil }//["nickname": nickname] }
    var encoding: ParameterEncoding { URLEncoding.default }
}

// 탈퇴사유 조회 GET /public/user/withdrawal
struct WithdrawalReasonsAPIRequest: ApiRequestProtocol {
    var isUseAccessToken: Bool { true }                // public이지만 토큰 포함해도 무방(서버 무시)
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.withdrawalReasons.url }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? { AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true) }
    var parameters: Parameters? { nil }
    var encoding: ParameterEncoding { URLEncoding.default }
}

// 회원탈퇴 POST /user/withdrawal
struct UserWithdrawalAPIRequest: ApiRequestProtocol {
    let withdrawalCategoryId: Int
    let reason: String

    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.withdrawal.url }
    var method: HTTPMethod { .post }
    var headers: HTTPHeaders? { AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true) }
    var parameters: Parameters? {
        
        var parameter: Parameters = [:]
        
        if  withdrawalCategoryId == -1 {
            parameter["withdrawalCategoryId"] = NSNull()
            parameter["reason"] = reason
            return parameter
            
        } else {
            parameter["withdrawalCategoryId"] = withdrawalCategoryId
            parameter["reason"] = reason
            return parameter
            
        }
    }
    var encoding: ParameterEncoding { JSONEncoding.default }
}

// 구독 정보 조회 GET  /my/subscriptions
struct MySubscriptionAPIRequest: ApiRequestProtocol {
    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.mySubscriptions.url }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? {
        AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true)
    }
    var parameters: Parameters? { nil }
    var encoding: ParameterEncoding { URLEncoding.default }
}

