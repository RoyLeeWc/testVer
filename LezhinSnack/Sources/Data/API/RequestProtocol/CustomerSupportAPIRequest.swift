//
//  CustomerSupportAPIRequest.swift
//  LezhinSnack
//
//  Created by lwc on 10/17/25.
//
import Alamofire
import Foundation


struct NoticeAPIRequest: ApiRequestProtocol {
    let noiceId: String
    
    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.notice(noiceId: noiceId) }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? { AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true) }
    var parameters: Parameters? { nil }
    var encoding: ParameterEncoding { URLEncoding.default }
}

struct NoticeListAPIRequest: ApiRequestProtocol {
    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.noticeList.url }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? { AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true) }
    var parameters: Parameters? { nil }
    var encoding: ParameterEncoding { URLEncoding.default }
}


struct FaqCategoryAPIRequest: ApiRequestProtocol {
    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.faqCategory.url }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? { AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true) }
    var parameters: Parameters? { nil }
    var encoding: ParameterEncoding { URLEncoding.default }
}

struct FaqListAPIRequest: ApiRequestProtocol {
    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { APIEndpoint.faqBase.url }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? { AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true) }
    var parameters: Parameters? { nil }
    var encoding: ParameterEncoding { URLEncoding.default }
}

struct FaqDetailAPIRequest: ApiRequestProtocol {
    let faqId: Int

    var isUseAccessToken: Bool { true }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog }
    var url: String { "\(APIEndpoint.faqBase.url)/\(faqId)" }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? { AppContext.shared.makeSnackAuthHeaders(includeUserId: true, includeBearer: true) }
    var parameters: Parameters? { nil }
    var encoding: ParameterEncoding { URLEncoding.default }
}
