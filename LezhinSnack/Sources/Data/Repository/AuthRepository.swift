//
//  AuthRepository.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/10/25.
//

import Foundation
import SwiftyUserDefaults

protocol AuthRepositoryProtocol {
    func loginGuest(parameters: [String: Any]) async throws -> AuthEntity
    func loginWithSavedData(parameters: [String: Any]) async throws -> AuthEntity
    func logoutAndLoginGuestMode(logoutParameters: [String: Any],guestModeParameters: [String: Any]) async throws -> AuthEntity
    func login(parameters: [String: Any]) async throws -> AuthEntity
    func fetchAgreement() async throws -> [AgreementEntity]
}

class AuthRepository: AuthRepositoryProtocol {
    
    
    func login(parameters: [String: Any]) async throws -> AuthEntity {
        let loginAPIRequest = SnsLoginAPIRequest(parameters: parameters)
        var snsLoginResponse: KRAuthDTO = try await NetworkService.shared.requestAsync(loginAPIRequest)
        
        if snsLoginResponse.result == LZSConstant.ResponseError {
            if snsLoginResponse.error?.code == LZSConstant.NotRegisteredUser {
                let signUpRequest = SnsSignUpAPIRequest(parameters: parameters)
                snsLoginResponse = try await NetworkService.shared.requestAsync(signUpRequest)
            }
        }
        
        guard snsLoginResponse.result == LZSConstant.ResponseSuccess,
              let data = snsLoginResponse.data,
              let userEmail = data.email,
              let userId = data.userId else {
            throw NSError(
                domain: "AuthError",
                code: -1,
                userInfo: nil
            )
        }
        
        await TokenService.shared.initializeTokens(
            accessToken: data.accessToken.token,
            refreshToken: data.refreshToken.token,
            accessExpiryTimestamp: Double(data.accessToken.expiredAt),
            refreshExpiryTimestamp: Double(data.refreshToken.expiredAt)
        )
        
        return AuthEntity(
            userId: "\(userId)",
            email: userEmail,
            accessToken: data.accessToken.token,
            refreshToken: data.refreshToken.token,
            accessExpiry: Double(data.accessToken.expiredAt),
            refreshExpiry: Double(data.refreshToken.expiredAt)
        )
        
    }
    
    
    func logoutAndLoginGuestMode(logoutParameters: [String: Any],guestModeParameters: [String: Any]) async throws -> AuthEntity {
        let logoutAPIRequest = LogoutAPIRequest(parameters: logoutParameters)
        
        let _: CommonAPISuccess = try await NetworkService.shared.requestAsync(logoutAPIRequest)

        let newUUID = LZSUtil.generateNewUniqueDeviceIdentifier()
        
        // 게스트 모드 파라미터 업데이트: 최신 UUID 기반으로 snsId, email, deviceId 갱신
        var updatedGuestModeParameters = guestModeParameters
        updatedGuestModeParameters["snsId"] = newUUID
        updatedGuestModeParameters["email"] = "\(newUUID)@apple_guest.com"
        updatedGuestModeParameters["deviceId"] = newUUID
        
        let guestModeLoginAPIRequest = GuestModeLoginAPIRequest(parameters: updatedGuestModeParameters)
        let guestModeLoginResponse: KRAuthDTO = try await NetworkService.shared.requestAsync(guestModeLoginAPIRequest)
        
        guard guestModeLoginResponse.result == LZSConstant.ResponseSuccess,
              let data = guestModeLoginResponse.data,
              let userEmail = data.email,
              let userId = data.userId else {
            throw NSError(
                domain: "AuthError",
                code: -1,
                userInfo: nil
            )
        }
        
        await TokenService.shared.initializeTokens(
            accessToken: data.accessToken.token,
            refreshToken: data.refreshToken.token,
            accessExpiryTimestamp: Double(data.accessToken.expiredAt),
            refreshExpiryTimestamp: Double(data.refreshToken.expiredAt)
        )
        
        return AuthEntity(
            userId: "\(userId)",
            email: userEmail,
            accessToken: data.accessToken.token,
            refreshToken: data.refreshToken.token,
            accessExpiry: Double(data.accessToken.expiredAt),
            refreshExpiry: Double(data.refreshToken.expiredAt)
        )
    }
    
    func loginGuest(parameters: [String: Any]) async throws -> AuthEntity {
        let guestRequest = GuestModeLoginAPIRequest(parameters: parameters)
        // NetworkService의 async 버전 호출 (예: URLSession.data(for:) 유사)
        let response: KRAuthDTO = try await NetworkService.shared.requestAsync(guestRequest)
        
        guard response.result == LZSConstant.ResponseSuccess,
              let data = response.data,
              let userEmail = data.email,
              let userId = data.userId else {
            throw NSError(
                domain: "AuthError",
                code: -1,
                userInfo: nil
            )
        }
        
        await TokenService.shared.initializeTokens(
            accessToken: data.accessToken.token,
            refreshToken: data.refreshToken.token,
            accessExpiryTimestamp: Double(data.accessToken.expiredAt),
            refreshExpiryTimestamp: Double(data.refreshToken.expiredAt)
        )
        
        return AuthEntity(
            userId: "\(userId)",
            email: userEmail,
            accessToken: data.accessToken.token,
            refreshToken: data.refreshToken.token,
            accessExpiry: Double(data.accessToken.expiredAt),
            refreshExpiry: Double(data.refreshToken.expiredAt)
        )
    }
    
    func loginWithSavedData(parameters: [String: Any]) async throws -> AuthEntity {
        let snsRequest = SnsLoginAPIRequest(parameters: parameters)
        let response: KRAuthDTO = try await NetworkService.shared.requestAsync(snsRequest)
        
        guard response.result == LZSConstant.ResponseSuccess,
              let data = response.data,
              let userEmail = data.email,
              let userId = data.userId else {
            throw NSError(
                domain: "AuthError",
                code: -1,
                userInfo: nil
            )
        }
        
        await TokenService.shared.initializeTokens(
            accessToken: data.accessToken.token,
            refreshToken: data.refreshToken.token,
            accessExpiryTimestamp: Double(data.accessToken.expiredAt),
            refreshExpiryTimestamp: Double(data.refreshToken.expiredAt)
        )
        
        return AuthEntity(
            userId: "\(userId)",
            email: userEmail,
            accessToken: data.accessToken.token,
            refreshToken: data.refreshToken.token,
            accessExpiry: Double(data.accessToken.expiredAt),
            refreshExpiry: Double(data.refreshToken.expiredAt)
        )
    }
    
    func fetchAgreement() async throws -> [AgreementEntity] {
        return [
            AgreementEntity(title: "서비스 이용약관",
                            agreementType: .required),
            AgreementEntity(title: "개인정보처리 방침",
                            agreementType: .required),
            AgreementEntity(title: "만 14세 이상 사용자 이용동의",
                            agreementType: .required),
            AgreementEntity(title: "마케팅 정보 수신 동의",
                            subtitle: "설정 메뉴에서 변경할 수 있습니다.",
                            agreementType: .optional),
        ]
    }
    
}
