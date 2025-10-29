//
//  MyListAPIRequest.swift
//  LezhinSnack
//
//  Created by lwc on 10/14/25.
//

import Alamofire
import Foundation


// 구매한 콘텐츠
struct PurchasedContentsAPIRequest: ApiRequestProtocol {
    let size: Int
    let page: Int
    let sort: ContentsListSort   // RECENT/OLDEST/EPISODE_UPDATED
    let isPaged: Bool?            // 필요 시 사용

    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String {APIEndpoint.purchasedContents.url}
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? { AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true) }
    var parameters: Parameters? {
        ["page": page,"size": size,"sort": sort.rawValue, "isPaged": isPaged]
    }
    var encoding: ParameterEncoding { URLEncoding.default }
}

// 찜한 콘텐츠
struct WishContentsAPIRequest: ApiRequestProtocol {
    let size: Int
    let page: Int
    let sort: ContentsListSort
    let isPaged: Bool?

    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.favoriteContents.url}
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? { AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true) }
    var parameters: Parameters? {
        ["page": page,"size": size,"sort": sort.rawValue, "isPaged": isPaged]
    }
    var encoding: ParameterEncoding { URLEncoding.default }
}

// 최근 시청
struct LastViewedContentsAPIRequest: ApiRequestProtocol {
    let size: Int
    let page: Int
    let sort: ContentsListSort
    let isPaged: Bool?

    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.lastViewedContents.url}
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? {
        AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true)
    }
    var parameters: Parameters? {
        ["page": page,"size": size,"sort": sort.rawValue, "isPaged": isPaged]
    }
    var encoding: ParameterEncoding { URLEncoding.default }
}


// 최근 시청목록 삭제
struct LastViewedBulkDeleteAPIRequest: ApiRequestProtocol {
    let contentsIds: [String]

    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.lastViewedContentsDelete.url }
    var method: HTTPMethod { .post }
    var headers: HTTPHeaders? {
        AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true)
    }
    var parameters: Parameters? {
        ["contentsIds": contentsIds]
    }
    var encoding: ParameterEncoding { JSONEncoding.default }
}

// 최근 찜목록 삭제
struct WishViewedBulkDeleteAPIRequest: ApiRequestProtocol {
    let contentsIds: [String]

    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.favoriteContentsDelete.url }
    var method: HTTPMethod { .post }
    var headers: HTTPHeaders? {
        AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true)
    }
    var parameters: Parameters? {
        ["contentsIds": contentsIds]
    }
    var encoding: ParameterEncoding { JSONEncoding.default }
}

// 최근 구매 작품 숨기기
struct PurchasedViewedBulkDeleteAPIRequest: ApiRequestProtocol {
    let contentsIds: [String]

    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.purchasedContentsDelete.url }
    var method: HTTPMethod { .post }
    var headers: HTTPHeaders? {
        AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true)
    }
    var parameters: Parameters? {
        ["contentsIds": contentsIds]
    }
    var encoding: ParameterEncoding { JSONEncoding.default }
}
