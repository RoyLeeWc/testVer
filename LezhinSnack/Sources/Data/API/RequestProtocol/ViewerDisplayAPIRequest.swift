//
//  DisplayAPIRequest.swift
//  LezhinSnack
//
//  Created by lwc on 9/18/25.
//


import Alamofire

struct DisplayVideoAPIRequest: ApiRequestProtocol {
    // MARK: Inputs
    let episodeId: String
    let drmType: String          // "WIDEVINE" | "FAIRPLAY"
    let drmLicenseUserId: String
    
    // MARK: ApiRequestProtocol
    var isUseAccessToken: Bool { true } // 문서에 Bearer 명시 → 토큰 사용
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.displayVideo(episodeId: episodeId) }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? {
        // SNACK 4종 + (옵션) User-Id + Bearer 포함
//        AppContext.shared.makeFullSnackHeaders()
        AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true)
    }
    var parameters: Parameters? {
        [
            "drmType": drmType,
            "drmLicenseUserId": drmLicenseUserId
        ]
    }
    var encoding: ParameterEncoding { URLEncoding.default }
}


struct DisplayContentsAPIRequest: ApiRequestProtocol {
    let contentsAlias: String
    
    var isUseAccessToken: Bool { true } // 로그인 시 isLiked/isFavorite/purchasedEpisodes 정확히 받기 위함
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.displayContents(alias: contentsAlias) }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? {
        AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true)
    }
    var parameters: Parameters? { nil }
    var encoding: ParameterEncoding { URLEncoding.default }
}

struct DisplayEpisodeAPIRequest: ApiRequestProtocol {
    let contentsAlias: String
    let episodeAlias: String

    var isUseAccessToken: Bool { true } // possessionCoin 등 사용자 종속값 포함 → 토큰 필요
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.displayEpisode(contentsAlias: contentsAlias, episodeAlias: episodeAlias) }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? {
        AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true)
    }
    var parameters: Parameters? { nil }
    var encoding: ParameterEncoding { URLEncoding.default }
}

struct PreviewRecommendationAPIRequest: ApiRequestProtocol {
    var isUseAccessToken: Bool { true } // 사용자 종속 추천 → 토큰 필요
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.previewRecommendation.url }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? {
        AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true)
    }
    var parameters: Parameters? { nil }
    var encoding: ParameterEncoding { URLEncoding.default }
}

struct ContentsEpisodesAPIRequest: ApiRequestProtocol {
    let contentsId: String

    var isUseAccessToken: Bool { true } // 사용자 컨텍스트가 섞일 가능성 고려
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.contentsEpisodes(contentsId: contentsId) }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? {
        AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true)
    }
    var parameters: Parameters? { nil }
    var encoding: ParameterEncoding { URLEncoding.default }
}
