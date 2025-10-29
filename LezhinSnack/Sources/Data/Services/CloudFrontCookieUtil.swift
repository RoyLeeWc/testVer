//
//  CloudFrontCookieUtil.swift
//  LezhinSnack
//
//  Created by lwc on 9/25/25.
//

import Foundation

enum CloudFrontCookieUtil {

    // MARK: 1) HTTPURLResponse의 Set-Cookie → CloudFront 쿠키 3종을 모아 Cookie 헤더 문자열로 조합
    static func buildCookieHeader(from response: HTTPURLResponse, apiURL: URL) -> String? {
        // Apple 표준 파서 사용 (Set-Cookie 여러 개/Expires 콤마 안전)
        guard let fields = response.allHeaderFields as? [String: String] else { return nil }
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: apiURL)

        var bag: [String: String] = [:]
        for c in cookies {
            switch c.name {
            case "CloudFront-Policy", "CloudFront-Signature", "CloudFront-Key-Pair-Id":
                bag[c.name] = c.value
            default: break
            }
        }
        guard
            let policy = bag["CloudFront-Policy"],
            let sign   = bag["CloudFront-Signature"],
            let kid    = bag["CloudFront-Key-Pair-Id"]
        else { return nil }

        // 순서는 의미 없지만 보기 좋게 고정
        return "CloudFront-Policy=\(policy); CloudFront-Signature=\(sign); CloudFront-Key-Pair-Id=\(kid)"
    }

    // MARK: 2) "Cookie: ..." 문자열을 key-value로 파싱 (내부 유틸)
    static func parseCookieHeader(_ header: String) -> [String: String] {
        header.split(separator: ";").reduce(into: [:]) { dict, part in
            let kv = part.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            guard kv.count == 2 else { return }
            dict[String(kv[0]).trimmingCharacters(in: .whitespaces)] = String(kv[1])
        }
    }

    // MARK: 3) Path 스코프 쿠키 설치(세그먼트 하위요청 전파 보장, 다중 비디오 충돌 방지)
    static func installPathScopedCookies(cookieHeader: String, manifestURL: URL) {
        let kv = parseCookieHeader(cookieHeader)
        guard
            let host = manifestURL.host,
            var path = manifestURL.deletingLastPathComponent().path.removingPercentEncoding
        else { return }

        if !path.hasSuffix("/") { path += "/" } // 디렉토리 형태 권장

        // 동일 이름 쿠키여도 Path가 다르면 공존 가능
        for name in ["CloudFront-Policy", "CloudFront-Signature", "CloudFront-Key-Pair-Id"] {
            guard let value = kv[name] else { continue }
            let props: [HTTPCookiePropertyKey: Any] = [
                .domain: host,
                .path: path,
                .name: name,
                .value: value,
                .secure: true
            ]
            if let cookie = HTTPCookie(properties: props) {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
    }
}
