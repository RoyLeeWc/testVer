//
//  BannerAPIRequest.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/13/25.
//

import Alamofire

struct BannerType {
    static let main = "MAIN"
    static let comic = "COMIC"
    static let comicRanking = "COMIC_RANKING"
    static let comicOriginal = "COMIC_ORIGINAL"
    static let comicNewest = "COMIC_NEWEST"
}

struct BannerAPIRequest: ApiRequestProtocol {
    var isUseAccessToken: Bool { false }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog ? true : false }
    var url: String { APIEndpoint.mainBanner.url }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? { AppContext.shared.commonHeader } // 필요에 따라 헤더 추가
    var parameters: Parameters? { _parameters }
    var encoding: ParameterEncoding { URLEncoding.default }
    
    private let _parameters: Parameters?
    
    init(parameters: Parameters?) {
        _parameters = parameters
    }
}
