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
    
//    func request<T: Decodable>(_ apiRequest: ApiRequestProtocol,
//                               decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, AFError> {
//
//        // 요청 로그
//        printApiLog(apiLogType: .requestLog, apiRequest)
//
//        // 요청 객체 만들어서 재사용
//        let req = session.request(apiRequest.url,
//                                  method: apiRequest.method,
//                                  parameters: apiRequest.parameters,
//                                  encoding: apiRequest.encoding,
//                                  headers: apiRequest.headers)
//
//        // ✅ 응답 로깅은 Data로
//        req.responseData { [weak self] res in
//            self?.logHTTP(apiRequest: apiRequest, request: req, response: res)
//        }
//
//        // 디코딩 스트림
//        return req.publishDecodable(type: T.self, decoder: decoder)
//                 .value()
//                 .eraseToAnyPublisher()
//    }
    
    
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
    
    private func logHTTP(apiRequest: ApiRequestProtocol,
                         request: DataRequest,
                         response: AFDataResponse<Data>) {
        guard apiRequest.isPrintLog else { return }

        let finalURL   = request.request?.url?.absoluteString ?? apiRequest.url
        let statusCode = response.response?.statusCode ?? -1
        let headers    = request.request?.allHTTPHeaderFields ?? [:]
        let bodyStr    = response.data.flatMap { String(data: $0, encoding: .utf8) } ?? "<no-body>"
        let errorDesc  = response.error?.localizedDescription ?? "none"
        let respHeaders = response.response?.allHeaderFields ?? [:]
        let prettyRespHeaders = prettyResponseHeaders(response.response)
        // 민감값 마스킹(Authorization 등)
        let maskedHeaders = headers.mapValues { key -> String in
            if key.lowercased().contains("authorization") { return "Bearer ****" }
            return key
        }

        let printString = """
        ┌────────────────────────────────────────────────────────────────────────
        │ ⏰ Final URL   : \(finalURL)
        │ 📄 Method      : \(apiRequest.method.rawValue)
        │ 🔢 Status      : \(statusCode)
        │ 🧾 ReqHeaders  : \(maskedHeaders)
        │ ⚙️ ReqParams   : \(LZSUtil.parsePrettyDictionary(dictionary: apiRequest.parameters))
        │ ❌ Error       : \(errorDesc)
        │ 🔢 RespBody    : \(bodyStr)
        │ 📨 RespHeaders : \(prettyRespHeaders)
        └────────────────────────────────────────────────────────────────────────
        """
        print("리스폰스 로그 : \n" + printString)
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
        
        //        // 응답 문자열 로그 출력
        //        if let responseString = try? await request.serializingString().value {
        //            printApiLog(apiLogType: .responseLog, apiRequest, responseString)
        //        }
        //
        //        // 응답 데이터를 디코딩하여 T 타입으로 반환
        //        let decodedData = try await request.serializingDecodable(T.self, decoder: decoder).value
        //        return decodedData
        
        
        // Data로 받고 UTF-8로만 로그 출력
        let data = try await request.serializingData().value
        let body = String(data: data, encoding: .utf8) ?? String(decoding: data, as: UTF8.self)
        printApiLog(apiLogType: .responseLog, apiRequest, body)
        // 같은 Data로 디코딩
        return try decoder.decode(T.self, from: data)
    }
    
    /// 디코딩 결과 + HTTPURLResponse(헤더 접근용) 동시 반환
    func requestAsyncWithResponse<T: Decodable>(_ apiRequest: ApiRequestProtocol,decoder: JSONDecoder = JSONDecoder()) async throws -> (T, HTTPURLResponse?, Data) {
        // 로그
        printApiLog(apiLogType: .requestLog, apiRequest)
        
        if apiRequest.isUseAccessToken == true && !TokenService.shared.isAccessTokenValid() {
            let ok = await TokenService.shared.refreshAccessToken()
            if !ok { throw NSError(domain: "AuthError", code: -1) }
        }
        
        let req = session.request(apiRequest.url,
                                  method: apiRequest.method,
                                  parameters: apiRequest.parameters,
                                  encoding: apiRequest.encoding,
                                  headers: apiRequest.headers)
        
        let res = await req.serializingData().response
        logHTTP(apiRequest: apiRequest, request: req, response: res)
        
        let data = res.data ?? Data()
        let body = String(data: data, encoding: .utf8) ?? String(decoding: data, as: UTF8.self)
        printApiLog(apiLogType: .responseLog, apiRequest, body)
        
        let decoded = try decoder.decode(T.self, from: data)
        return (decoded, res.response, data)
    }
    
    private func prettyResponseHeaders(_ httpResponse: HTTPURLResponse?) -> String {
        guard let httpResponse = httpResponse else { return "<no-headers>" }
        
        // AnyHashable → [String: Any] 로 정규화
        var dict: [String: Any] = [:]
        
        httpResponse.allHeaderFields.forEach { k, v in
            dict[String(describing: k)] = String(describing: v)
        }
        // 필요 시 마스킹 (Authorization 등). Set-Cookie는 디버깅 위해 그대로 둠.
        var masked = dict
        for (k, v) in dict {
            if k.lowercased() == "authorization" {
                masked[k] = "Bearer ****"
            }
        }
        return LZSUtil.parsePrettyDictionary(dictionary: masked)
    }

    private func printResponseHeadersLog(apiLogType: APILogType,
                                         _ apiRequest: ApiRequestProtocol,
                                         _ httpResponse: HTTPURLResponse?) {
        guard apiRequest.isPrintLog else { return }
        let headers = prettyResponseHeaders(httpResponse)
        let status  = httpResponse?.statusCode ?? -1
        let url     = httpResponse?.url?.absoluteString ?? apiRequest.url
        let block = """
        ┌────────────────────────────────────────────────────────────────────────────────────────
        │ ⏰ Final URL   : \(url)
        │ 🔢 Status      : \(status)
        │ 📨 RespHeaders : \(headers)
        └────────────────────────────────────────────────────────────────────────────────────────
        """
        print("리스폰스 헤더 : \n" + block)
    }

    
//    func requestAsync<T: Decodable>(_ apiRequest: ApiRequestProtocol,
//                                    decoder: JSONDecoder = JSONDecoder()) async throws -> T {
//        // 요청 로그
//        printApiLog(apiLogType: .requestLog, apiRequest)
//
//        // 토큰 확인/갱신
//        if apiRequest.isUseAccessToken == true && !TokenService.shared.isAccessTokenValid() {
//            let ok = await TokenService.shared.refreshAccessToken()
//            if !ok { throw NSError(domain: "AuthError", code: -1) }
//        }
//
//        // 요청 생성
//        let req = session.request(apiRequest.url,
//                                  method: apiRequest.method,
//                                  parameters: apiRequest.parameters,
//                                  encoding: apiRequest.encoding,
//                                  headers: apiRequest.headers)
//
//        // ✅ Data 응답 확보 + 로깅
//        let res = await req.serializingData().response
//        logHTTP(apiRequest: apiRequest, request: req, response: res)
//
//        // ✅ 직접 디코딩
//        let data = res.data ?? Data()
//        do {
//            return try decoder.decode(T.self, from: data)
//        } catch {
//            if apiRequest.isPrintLog {
//                print("❗️Decode failed: \(error)\nRawBody:\n\(LZSUtil.prettyJSONString(data: data))")
//            }
//            throw error
//        }
//    }
}
