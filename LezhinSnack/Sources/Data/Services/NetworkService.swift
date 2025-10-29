//
//  NetworkService.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/5/25.
//

import Foundation
import Alamofire
import Combine



enum APILogType: String {
    case requestLog = "리퀘스트 로그"
    case responseLog = "리스폰스 로그"
}

protocol ApiRequestProtocol {
    var isUseAccessToken: Bool { get }
    var isPrintLog: Bool { get }            // 로그 여부
    var url: String { get }                 // API 호출 URL
    var method: HTTPMethod { get }          // HTTP 메소드 (GET, POST 등)
    var headers: HTTPHeaders? { get }       // 공통 또는 요청별 헤더
    var parameters: Parameters? { get }     // 요청 파라미터 (바디, 쿼리 등)
    var encoding: ParameterEncoding { get } // 파라미터 인코딩 방식
}

final class NetworkService {
    static let shared = NetworkService()
    private let session: Session
    
    private init() {
        session = Session() // 필요시 커스텀 설정 추가 가능
    }
    
    func request<T: Decodable>(_ apiRequest: ApiRequestProtocol, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, AFError> {
        
        printApiLog(apiLogType: .requestLog, apiRequest)
        
        return session.request(apiRequest.url,
                               method: apiRequest.method,
                               parameters: apiRequest.parameters,
                               encoding: apiRequest.encoding,
                               headers: apiRequest.headers)
        .responseString { [weak self] result in
            self?.printApiLog(apiLogType: .responseLog, apiRequest, result.value)
            if let httpResponse = result.response,
               let dateString = httpResponse.allHeaderFields["Date"] as? String,
               let serverDate = DateFormatter.rfc1123.date(from: dateString) {
//                TokenService.shared.updateServerTime(with: serverDate)
            } else {
                // Date 값이 없거나 파싱에 실패하면 시스템 시간을 사용
//                TokenService.shared.updateServerTime(with: Date())
            }
        }
        .publishDecodable(type: T.self, decoder: decoder)
        .value()
        .eraseToAnyPublisher()
    }
    
    
    func printApiLog(apiLogType: APILogType, _ apiRequest: ApiRequestProtocol, _ result: String? = nil) {
        if apiRequest.isPrintLog {
            let printString = """
            ┌──────────────────────────────────────────────────────────────────────────────────────────────
            │ ⏰ Url        : \(apiRequest.url)
            │ 📄 Method     : \(apiRequest.method.rawValue)
            │ 🔢 Headers    : \(String(describing: apiRequest.headers))
            │ ⚙️ requestParam       : \(LZSUtil.parsePrettyDictionary(dictionary: apiRequest.parameters))
            │ 🔢 responseValue      : \(LZSUtil.parsePrettyJsonString(jsonString: result))
            └──────────────────────────────────────────────────────────────────────────────────────────────
            """
            print("\(apiLogType.rawValue) : \n"+printString)
        }
    }
}

extension NetworkService {
    func requestAsync<T: Decodable>(_ apiRequest: ApiRequestProtocol, decoder: JSONDecoder = JSONDecoder()) async throws -> T {
        // 요청 로그 출력
        printApiLog(apiLogType: .requestLog, apiRequest)
        
        if apiRequest.isUseAccessToken == true && !TokenService.shared.isAccessTokenValid() {
            let refreshTokenSuccess = await TokenService.shared.refreshAccessToken()
            if refreshTokenSuccess == false {
                throw NSError(domain: "AuthError", code: -1, userInfo: nil)
            }
        }
        
        // Alamofire의 요청 생성
        let request = session.request(apiRequest.url,
                                      method: apiRequest.method,
                                      parameters: apiRequest.parameters,
                                      encoding: apiRequest.encoding,
                                      headers: apiRequest.headers)
        
        // 응답 문자열 로그 출력
        if let responseString = try? await request.serializingString().value {
            printApiLog(apiLogType: .responseLog, apiRequest, responseString)
        }
        
        // 응답 데이터를 디코딩하여 T 타입으로 반환
        let decodedData = try await request.serializingDecodable(T.self, decoder: decoder).value
        return decodedData
    }
}
