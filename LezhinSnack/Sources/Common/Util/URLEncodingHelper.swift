//
//  URLEncodingHelper.swift
//  LezhinSnack
//
//  Created by Claude on 10/30/25.
//

import Foundation

/// URL 인코딩 문제를 해결하는 헬퍼
/// 한글, 특수문자, 1080p 등이 포함된 URL을 안전하게 처리
enum URLEncodingHelper {

    /// 서버에서 받은 URL 문자열을 안전하게 URL로 변환
    /// - Parameter urlString: 원본 URL 문자열 (부분 인코딩되었을 수 있음)
    /// - Returns: 유효한 URL 객체, 실패 시 nil
    static func safeURL(from urlString: String) -> URL? {
        // 빈 문자열 체크
        guard !urlString.isEmpty else { return nil }

        // 1단계: 원본 그대로 시도 (이미 완전히 인코딩된 경우)
        if let url = URL(string: urlString) {
            return url
        }

        // 2단계: 디코딩 후 URLComponents로 재구성 (권장 방법)
        let decoded = urlString.removingPercentEncoding ?? urlString
        if var components = URLComponents(string: decoded) {
            // URLComponents가 자동으로 올바르게 인코딩해줌
            return components.url
        }

        // 3단계: 수동 파싱 및 재조립 (최후의 수단)
        return manuallyFixURL(decoded)
    }

    /// URL을 수동으로 파싱하고 재조립
    private static func manuallyFixURL(_ urlString: String) -> URL? {
        // URL 구성 요소 분리
        guard let schemeEndIndex = urlString.range(of: "://")?.upperBound else {
            return nil
        }

        let scheme = String(urlString[..<urlString.index(schemeEndIndex, offsetBy: -3)])
        let remainder = String(urlString[schemeEndIndex...])

        // Host와 Path 분리
        guard let firstSlash = remainder.firstIndex(of: "/") else {
            // Path가 없는 경우
            return URL(string: "\(scheme)://\(remainder)")
        }

        let host = String(remainder[..<firstSlash])
        let path = String(remainder[firstSlash...])

        // Path를 인코딩 (이미 인코딩된 부분은 유지)
        let encodedPath = encodePathComponent(path)

        // 재조립
        let fixedURLString = "\(scheme)://\(host)\(encodedPath)"
        return URL(string: fixedURLString)
    }

    /// Path 컴포넌트를 안전하게 인코딩
    /// - 이미 인코딩된 %XX는 보존
    /// - 한글, 특수문자는 인코딩
    private static func encodePathComponent(_ path: String) -> String {
        // Path를 / 로 분리
        let components = path.split(separator: "/", omittingEmptySubsequences: false)

        let encoded = components.map { component -> String in
            let str = String(component)

            // 이미 완전히 인코딩되었는지 확인
            if isFullyEncoded(str) {
                return str
            }

            // 디코딩 후 재인코딩
            let decoded = str.removingPercentEncoding ?? str
            return decoded.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? str
        }

        return "/" + encoded.joined(separator: "/")
    }

    /// 문자열이 이미 완전히 URL 인코딩되었는지 확인
    private static func isFullyEncoded(_ string: String) -> Bool {
        // %가 있으면서 디코딩 가능하면 이미 인코딩됨
        if string.contains("%"),
           let decoded = string.removingPercentEncoding,
           decoded != string {
            return true
        }
        return false
    }
}

// MARK: - 추가 헬퍼 함수
extension URLEncodingHelper {

    /// URL 문자열 검증 및 로깅
    static func validateAndLog(_ urlString: String) -> URL? {
        let url = safeURL(from: urlString)

        #if DEBUG
        if url == nil {
            print("⚠️ [URLEncodingHelper] URL 변환 실패:")
            print("   원본: \(urlString)")
            if let decoded = urlString.removingPercentEncoding {
                print("   디코딩: \(decoded)")
            }
        } else {
            print("✅ [URLEncodingHelper] URL 변환 성공")
        }
        #endif

        return url
    }

    /// 여러 URL 시도 (fallback 목록)
    static func tryURLs(_ urlStrings: [String]) -> URL? {
        for urlString in urlStrings {
            if let url = safeURL(from: urlString) {
                return url
            }
        }
        return nil
    }
}
