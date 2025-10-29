//
//  CurationListAPIRequest.swift
//  LezhinSnack
//
//  Created by lwc on 9/10/25.
//
import Alamofire
import SwiftyUserDefaults
import Foundation

/// 진열 목록 조회
struct CurationListAPIRequest: ApiRequestProtocol {
    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { true }
    var url: String { APIEndpoint.curationList.url }
    var method: HTTPMethod { .get }
//    var headers: HTTPHeaders? { AppContext.shared.makeSnackHeaders(userIdHeader: "553") }
    var headers: HTTPHeaders? { AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true)}
    
    var parameters: Parameters? { nil }
    var encoding: ParameterEncoding { URLEncoding.default }
}

/// 유저데이터 - 랭킹조회
struct ContentsRankingAPIRequest: ApiRequestProtocol {
    let period: String
    let topN: Int
    let type: String

    var isUseAccessToken: Bool { false }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.contentsRanking.url }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? {
        AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: false)
//        AppContext.shared.makeSnackHeaders(userIdHeader: "553")
    }
    var parameters: Parameters? {
        [
            "period": period,     // DAILY, WEEKLY, MONTHLY, YEARLY, ALL_TIME
            "topN": topN,                  // 예: 12
            "type": type          // MOST_VIEWED, MOST_PURCHASE, MOST_LIKED, MOST_FAVORITE
        ]
    }
    var encoding: ParameterEncoding { URLEncoding.default }
}

/// 진열 배너 조회
struct ContentsBannerAPIRequest: ApiRequestProtocol {
    let curationId: String
    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.contentsBanner.url }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? {
        AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true)
//        AppContext.shared.makeSnackHeaders(userIdHeader: "553")
    }
    var parameters: Parameters? {
        [ "curationId": curationId ]
    }
    var encoding: ParameterEncoding { URLEncoding.default }
}

/// 연재중인 컨텐츠 조회
struct ContentsOngoingAPIRequest: ApiRequestProtocol {
    var isUseAccessToken: Bool { false }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.contentsOngoing.url }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? {
        AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: false)
//        AppContext.shared.makeSnackHeaders(userIdHeader: "553")
    }
    var parameters: Parameters? { nil }
    var encoding: ParameterEncoding { URLEncoding.default }
}

/// 내가 시청중인 작품 조회
struct ContentsLastWatchAPIRequest: ApiRequestProtocol {
    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.contentsLastWatch.url }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? {
        AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true)
    }
    var parameters: Parameters? { nil }
    var encoding: ParameterEncoding { URLEncoding.default }
}

/// 콘텐츠(작품) 설정 조회
struct ContentsCurationContentsAPIRequest: ApiRequestProtocol {
    let curationId: String
    var isUseAccessToken: Bool { false }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.curationContents.url }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? {
//        AppContext.shared.makeSnackHeaders(userIdHeader: "553")
        AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: false)
    }
    var parameters: Parameters? {
        [ "curationId": curationId ]
    }
    var encoding: ParameterEncoding { URLEncoding.default }
}

