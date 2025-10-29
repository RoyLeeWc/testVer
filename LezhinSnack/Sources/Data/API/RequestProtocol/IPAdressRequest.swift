//
//  IPAdressService.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/8/25.
//

import Alamofire
import Combine


struct IPAddressAPIRequest: ApiRequestProtocol {
    var isUseAccessToken: Bool { false }
    var isPrintLog: Bool { AppContext.shared.isPrintAllApiLog ? true : false }
    var url: String { APIEndpoint.ipAddress.url }
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders? { nil } // 필요에 따라 헤더 추가
    var parameters: Parameters? { nil }
    var encoding: ParameterEncoding { URLEncoding.default }
}
