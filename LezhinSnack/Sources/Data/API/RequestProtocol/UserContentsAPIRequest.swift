//
//  UserContentsAPIRequest.swift
//  LezhinSnack
//
//  Created by lwc on 9/18/25.
//

import Alamofire
import Foundation


struct ContentsLikeAPIRequest: ApiRequestProtocol {
    let contentsId: String
    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.contentsLike(contentsId: contentsId) }
    var method: HTTPMethod { .post }
    var headers: HTTPHeaders? { AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true) }
    var parameters: Parameters? { nil }
    var encoding: ParameterEncoding { JSONEncoding.default }
}

struct ContentsUnlikeAPIRequest: ApiRequestProtocol {
    let contentsId: String
    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.contentsLike(contentsId: contentsId) } 
    var method: HTTPMethod { .delete }
    var headers: HTTPHeaders? { AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true) }
    var parameters: Parameters? { nil }  // 바디 없음
    var encoding: ParameterEncoding { URLEncoding.default }
}

struct ContentsFavoriteAPIRequest: ApiRequestProtocol {
    let contentsId: String
    let episodeId: String
    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.contentsFavorite(contentsId: contentsId) }
    var method: HTTPMethod { .post }
    var headers: HTTPHeaders? {
        AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true)
    }
    var parameters: Parameters? { ["episodeId": episodeId] }
    var encoding: ParameterEncoding { JSONEncoding.default }
}

struct ContentsUnfavoriteAPIRequest: ApiRequestProtocol {
    let contentsId: String
    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.contentsFavorite(contentsId: contentsId) }
    var method: HTTPMethod { .delete }
    var headers: HTTPHeaders? {
        AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true)
    }
    var parameters: Parameters? { nil }
    var encoding: ParameterEncoding { URLEncoding.default }
}

struct EpisodeViewCountAPIRequest: ApiRequestProtocol {
    let contentsId: String
    let episodeId: String
    /// 바디에 들어갈 구독정보
    struct SubscriptionInfo {
        let subscriptionId: String
        let productCode: String
    }
    let subscriptionInfo: SubscriptionInfo?
    let isViewCountOnly: Bool? ///맛보기(true) / 일반(nil 또는 false)
    
    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.episodeViewCount(contentsId: contentsId, episodeId: episodeId) }
    var method: HTTPMethod { .post }
    var headers: HTTPHeaders? { AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true) }
    // nil이면 {:} 보냄
    var parameters: Parameters? {
        var body: [String: Any] = [:]
        if let sub = subscriptionInfo {
            body["subscriptionInfo"] = [
                "subscriptionId": sub.subscriptionId,
                "productCode": sub.productCode
            ]
        } else {
            // 서버 요구사항: null 명시
            body["subscriptionInfo"] = NSNull()
        }
        
        if let isViewCountOnly = isViewCountOnly {
            body["isViewCountOnly"] = isViewCountOnly
        }
        return body
    }
    var encoding: ParameterEncoding { JSONEncoding.default }
}

//purchasedEpisodes
struct PurchasedEpisodeAPIRequest: ApiRequestProtocol {
    let contentsId: String
    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.purchasedEpisodes(contentsId: contentsId) }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? { AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true) }
    var parameters: Parameters? { [ "contentsId": contentsId ] }
    var encoding: ParameterEncoding { URLEncoding.default }
    
}
