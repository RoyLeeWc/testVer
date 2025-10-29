//
//  TokkenService.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/8/25.
//

import Foundation
import SwiftyUserDefaults
import Alamofire
import Combine
import Kronos

final class TokenService {
    static let shared = TokenService()
    private init() {}
    
    var subscriptions = Set<AnyCancellable>()
    
    // MARK: - 저장된 토큰 및 시간 정보
    var accessToken: String {
        get { Defaults[\.accessToken] }
        set { Defaults[\.accessToken] = newValue }
    }
    
    var refreshToken: String {
        get { Defaults[\.refreshToken] }
        set { Defaults[\.refreshToken] = newValue }
    }
    
    var accessTokenExpiryDate: Date? {
        get { Defaults[\.accessTokenExpiryDate] }
        set { Defaults[\.accessTokenExpiryDate] = newValue }
    }
    
    var refreshTokenExpiryDate: Date? {
        get { Defaults[\.refreshTokenExpiryDate] }
        set { Defaults[\.refreshTokenExpiryDate] = newValue }
    }
    
    var serverTimeOffset: TimeInterval {
        get { Defaults[\.serverTimeOffset] }
        set { Defaults[\.serverTimeOffset] = newValue }
    }
    
//    // MARK: - 서버 시간 오프셋 업데이트
//    /// 서버에서 받은 시간을 바탕으로 오프셋 계산
//    func updateServerTime(with serverTime: Date) {
//        serverTimeOffset = serverTime.timeIntervalSince(Date())
//    }
//    
//    // MARK: - 서버 기준 현재 시간
//    func currentServerTime() -> Date {
//        return Date().addingTimeInterval(serverTimeOffset)
//    }
    
    // MARK: - 토큰 유효성 검사
    /// 엑세스토큰 유효성 검사
    func isAccessTokenValid() -> Bool {
        guard let expiry = accessTokenExpiryDate else { return false }
        return Clock.now ?? Date() < expiry
    }
    
    /// 리프레스토큰 유효성 검사
    func isRefreshTokenValid() -> Bool {
        guard let expiry = refreshTokenExpiryDate else { return false }
        return Clock.now ?? Date() < expiry
    }
    
    // MARK: - 토큰 갱신 로직
    /// 리프레스토큰을 활용해 새로운 토큰 정보를 받아와 갱신하는 함수
    func refreshAccessToken() async -> Bool {
        do {
            
            guard isRefreshTokenValid() else {
                // TODO: 세션 정리/로그아웃 등 후속 처리
                await clearAll()
                return false
            }
            
            let parameters: Parameters = [
                "accessToken": accessToken,
                "refreshToken": refreshToken,
                "ipAddress": AppContext.shared.deviceIPAddress,
                "deviceId": AppContext.shared.deviceUniqueID,
                "deviceModel": AppContext.shared.deviceModelName
            ]

            let refreshRequest = RefreshTokenAPIRequest(parameters: parameters)
            let response: AuthRefreshDTO = try await NetworkService.shared.requestAsync(refreshRequest)
            
            if response.responseCode == APIResultType.success {
                guard let accessToken = response.data?.accessToken.token,
                      let refreshToken = response.data?.refreshToken.token,
                      let accessTokenExpiryDate = response.data?.accessToken.expiredAt,
                      let refreshTokenExpiryDate = response.data?.refreshToken.expiredAt
                else {
                    return false
                }
                
                // 서버 타임스탬프가 ms 기준이라면 초단위 변환
                let accessExpSec  = Double(accessTokenExpiryDate)
                let refreshExpSec = Double(refreshTokenExpiryDate)
                
                self.accessToken = accessToken
                self.refreshToken = refreshToken
                self.accessTokenExpiryDate = Date(timeIntervalSince1970: accessExpSec / 1000)
                self.refreshTokenExpiryDate = Date(timeIntervalSince1970: refreshExpSec / 1000)
                
                return true
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    // MARK: - 초기 토큰 설정 (로그인 시)
    /// 로그인 성공 후 서버에서 받은 토큰 및 시간 정보를 초기화
    func initializeTokens(accessToken: String,
                          refreshToken: String,
                          accessExpiryTimestamp: Double,
                          refreshExpiryTimestamp: Double) async {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.accessTokenExpiryDate = Date(timeIntervalSince1970: accessExpiryTimestamp / 1000)
        self.refreshTokenExpiryDate = Date(timeIntervalSince1970: refreshExpiryTimestamp / 1000)
    }
    
    func clearAll() async {
        Defaults.accessToken = ""
        Defaults.refreshToken = ""
        Defaults.accessTokenExpiryDate = nil
        Defaults.refreshTokenExpiryDate = nil
        Defaults.userLoginType = AuthProvider.IOS_GUEST.rawValue
        Defaults.userEmail = ""
        Defaults.snsId = ""
        Defaults.userId = 0
        Defaults.isAgreeMarketing = false
    }
}
