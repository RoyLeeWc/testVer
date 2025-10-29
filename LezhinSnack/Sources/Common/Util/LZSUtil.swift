//
//  BalconyUtil.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/8/25.
//

import SwiftyUserDefaults
import UIKit
import Toast
import Kronos
import WebKit
import AVKit

class LZSUtil {
    
    // 설정 -> 일반 -> 우선순위 언어중에 최상단 언어로 기본언어 설정
    static func getPrimaryLanguageCode() -> String {
        var primaryLanguageFromApple = "N/A"
        if let languages = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String],
           let firstLanguage = languages.first {
            primaryLanguageFromApple = firstLanguage.split(separator: "-").first.map(String.init) ?? firstLanguage
        }
        
        return primaryLanguageFromApple
    }
    
    static func retrieveUniqueDeviceIdentifier() -> String {
        // 앱 이름을 서비스 이름으로 사용 (없을 경우 적절한 기본값 설정)
        guard let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String else {
            return ""
        }
        
        let account = AppContext.shared.guestModeId
        
        // Keychain에서 기존 UUID 검색
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: appName,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == errSecSuccess {
            if let data = dataTypeRef as? Data,
               let storedUUID = String(data: data, encoding: .utf8),
               !storedUUID.isEmpty {
                // Keychain에 존재하면 UserDefaults에 동기화
                Defaults.guestModeId = storedUUID
                return storedUUID
            }
        }
        
        // Keychain에서 찾지 못한 경우, UserDefaults 확인
        if !Defaults.guestModeId.isEmpty {
            return Defaults.guestModeId
        }
        
        // 둘 다 없으면 새로운 UUID 생성 후 저장
        let newUUID = UUID().uuidString
        if let uuidData = newUUID.data(using: .utf8) {
            let addQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: appName,
                kSecAttrAccount as String: account,
                kSecValueData as String: uuidData,
                kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
            ]
            
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            if addStatus != errSecSuccess {
                // 저장 실패 시 추가 처리가 필요하면 여기에 구현
            }
        }
        
        // UserDefaults에도 저장
        Defaults.guestModeId = newUUID
        return newUUID
    }
    
    static func generateNewUniqueDeviceIdentifier() -> String {
        guard let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String else {
            return ""
        }
        
        // 기존 account는 AppContext.shared.guestModeId의 값을 사용한다고 가정
        let account = AppContext.shared.guestModeId
        
        // 기존 Keychain 항목 삭제
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: appName,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(deleteQuery as CFDictionary)
        
        // 새로운 UUID 생성
        let newUUID = UUID().uuidString
        guard let uuidData = newUUID.data(using: .utf8) else { return newUUID }
        
        // Keychain에 신규 UUID 저장 (account는 기존 account 값 사용)
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: appName,
            kSecAttrAccount as String: account,
            kSecValueData as String: uuidData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
        if addStatus != errSecSuccess {
            // 저장 실패 시 필요한 처리(예: 로그 남기기) 추가 가능
        }
        
        // UserDefaults 업데이트 (컨텍스트는 그대로 유지)
        Defaults.guestModeId = newUUID
        
        return newUUID
    }
    
    static func getIPAddress() -> String {
        var cellularIPv4: String?
        var wifiIPv4: String?
        var fallbackIPv6: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        if getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr {
            var ptr: UnsafeMutablePointer<ifaddrs>? = firstAddr
            while let interface = ptr?.pointee {
                let addrFamily = interface.ifa_addr.pointee.sa_family
                let name = String(cString: interface.ifa_name)
                
                // IPv4 주소 처리
                if addrFamily == UInt8(AF_INET) {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    let saLen = socklen_t(MemoryLayout<sockaddr_in>.size)
                    if getnameinfo(interface.ifa_addr, saLen, &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                        let address = String(cString: hostname)
                        if name == "pdp_ip0" {  // 셀룰러 인터페이스
                            cellularIPv4 = address
                        } else if name == "en0" {  // Wi‑Fi 인터페이스
                            wifiIPv4 = address
                        }
                    }
                }
                // IPv6 주소 처리 (백업용)
                else if addrFamily == UInt8(AF_INET6) {
                    if fallbackIPv6 == nil { // 최초 IPv6 주소만 저장
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        let saLen = socklen_t(MemoryLayout<sockaddr_in6>.size)
                        if getnameinfo(interface.ifa_addr, saLen, &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                            fallbackIPv6 = String(cString: hostname)
                        }
                    }
                }
                ptr = interface.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        
        // 우선순위: 셀룰러 IPv4 > Wi‑Fi IPv4 > IPv6
        return cellularIPv4 ?? wifiIPv4 ?? fallbackIPv6 ?? ""
    }
    
    static func decode(jwtToken jwt: String) -> [String: Any] {
        func base64UrlDecode(_ value: String) -> Data? {
            var base64 = value
                .replacingOccurrences(of: "-", with: "+")
                .replacingOccurrences(of: "_", with: "/")
            
            let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
            let requiredLength = 4 * ceil(length / 4.0)
            let paddingLength = requiredLength - length
            if paddingLength > 0 {
                let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
                base64 = base64 + padding
            }
            return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
        }
        func decodeJWTPart(_ value: String) -> [String: Any]? {
            guard let bodyData = base64UrlDecode(value),
                  let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
                return nil
            }
            
            return payload
        }
        
        let segments = jwt.components(separatedBy: ".")
        return decodeJWTPart(segments[1]) ?? [:]
    }
    
    
    static func parsePrettyJsonString(jsonString: String?) -> String {
        guard let jsonString = jsonString,
              let jsonData = jsonString.data(using: .utf8) else {
            return ""
        }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            return String(data: prettyData, encoding: .utf8) ?? ""
        } catch {
            print("JSON 파싱 에러: \(error.localizedDescription)")
            return ""
        }
    }
    
    static func parsePrettyDictionary(dictionary: [String: Any]?) -> String {
        guard let dictionary = dictionary,
              let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted),
              let jsonString = String(data: data, encoding: .utf8)
        else {
            return "Invalid JSON"
        }
        return jsonString
    }
    
    
    static func makeShortFormToastStyle() -> ToastStyle {
        var toastStyle = ToastStyle()
        toastStyle.backgroundColor = .gray
        toastStyle.titleColor = UIColor(.backgroundDefault)
        
        return toastStyle
    }
    
    
    static func getCurrentTimeDate() -> Date {
        return Clock.now ?? Date()
    }

    static func getCurrentTimeString(isUseUnixTime: Bool = false) -> String {
        let currentTime = Clock.now ?? Date()
        return isUseUnixTime ? String(Int(currentTime.timeIntervalSince1970)) : currentTime.description
    }
    
    
    static func getCurrentRegionCode() -> String {
        return Locale.current.region?.identifier ?? "N/A"
    }

    static func getCurrentTimeUnixInt64() -> Int64 {
        let currentTime = Clock.now ?? Date()
        return Int64(currentTime.timeIntervalSince1970)
    }
    
    
    static func isNotGuestMode() -> Bool {
        if Defaults.userLoginType != SnsLoginType.guestMode.rawValue {
            return true
        } else {
            return false
        }
    }
    
    
    static func balconyTypeUrl(urlString: String) -> URLRequest? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue(AppContext.shared.xBalconyId, forHTTPHeaderField: "x-balcony-id")
        request.setValue(AppContext.shared.xPlatform, forHTTPHeaderField: "x-platform")
        return request
    }
    
    
    
    static func makeBalconyWebView() -> WKWebView {
            let contentController = WKUserContentController()
            let config = WKWebViewConfiguration()
            config.userContentController = contentController
            config.dataDetectorTypes = []
            config.defaultWebpagePreferences.preferredContentMode = .mobile
            config.applicationNameForUserAgent = String(format : "%@ [deviceId:%@,deviceModel:%@]","balcony_ios_app" ,AppContext.shared.deviceUniqueID, AppContext.shared.deviceModelName)
            
            
            let webView = WKWebView(frame: .zero,configuration: config)
            webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
            
            return webView
    }
    
    
    static func extractValue<T>(from dictionary: [String: Any], forKey key: String) -> T? {
        return dictionary[key] as? T
    }
    
    
    
    
    static func makeTagView(type: TagType,
                            tagImageSize: CGSize = CGSize(width: 20,
                                                          height: 20)) -> UIView {
        let view = UIView()
        let imageView = UIImageView()
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.equalTo(tagImageSize.width)
            make.height.equalTo(tagImageSize.height)
            make.centerX.centerY.equalToSuperview()
        }
        
        switch type {
        case .lezhin:
            view.backgroundColor = UIColor(.lezhinBrandRed)
            imageView.image = UIImage(named: "lezhinIcon")
        case .bomtoon:
            view.backgroundColor = UIColor(.bomtoonBrandPink)
            imageView.image = UIImage(named: "bomtoonIcon")
        case .original:
            view.backgroundColor = UIColor(.foregroundDisabled)
            imageView.image = UIImage(named: "nonWebtoonIp")
        case .onlyTag: break
        }
        
        
        return view
    }
    
    static func getSafeAreaFrame() -> CGRect {
        let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        let windowBounds = keyWindow?.bounds ?? UIScreen.main.bounds
        let windowInsets = keyWindow?.safeAreaInsets ?? .zero
        return windowBounds.inset(by: windowInsets)
    }
    
    static func getSafeAreaInsets() -> UIEdgeInsets {
        let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        return keyWindow?.safeAreaInsets ?? .zero
    }
    
    
    static func formatTime(_ time: CMTime?) -> String {
        
        guard let time = time else {
            return "0:00"
        }
        
        let secondsDouble = CMTimeGetSeconds(time)
        // 유한하고 0보다 큰 값만 처리
        guard secondsDouble.isFinite && secondsDouble > 0 else {
            return "0:00"
        }
        let totalSeconds = Int(secondsDouble)
        let hours   = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            // 시가 1 이상일 때 -> "H:MM:SS" (시간도 한 자릿수면 앞 0 없이)
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            // 시가 0일 때 -> "M:SS"
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    
    static func getAppVersion() -> String {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleShortVersionString"] as? String else {return "1"}
        return version
    }
    
    
    static func getRandomUIColor() -> UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    
}
