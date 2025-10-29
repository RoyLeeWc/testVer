//
//  AuthRepository.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/10/25.
//

import Foundation
import SwiftyUserDefaults
import UIKit

enum AuthRepositoryError: Error {
    case api(code: String, message: String)
}

protocol AuthRepositoryProtocol {
    func loginGuest(parameters: [String: Any]) async throws -> AuthEntity
    func fetchAgreement() async throws -> [AgreementEntity]
    func welcomeFetchAgreement() async throws -> [AgreementEntity]
    
    ///--------------
    func snackLogin(provider: AuthProvider, email: String, token: String,
                    deviceId: String, deviceModel: String, pid: String, isGuest: Bool) async throws -> AuthEntity
    func snackSignup(provider: AuthProvider,
                   email: String?,
                   token: String,
                   deviceId: String,
                   deviceModel: String,
                   pid: String,
                   isGuest: Bool?,
                   isAgreeMarketing: Bool,
                   isAgreePushNotification: Bool,
                   guestId: String?) async throws -> AuthJoinDataDTO
    
    func snackLogout(refreshToken: String) async throws
}

class AuthRepository: AuthRepositoryProtocol {
    
    func snackLogin(provider: AuthProvider,
                    email: String,
                    token: String,
                    deviceId: String,
                    deviceModel: String,
                    pid: String = ProcessInfo.processInfo.globallyUniqueString,
                    isGuest: Bool = false) async throws -> AuthEntity {
        
        let body: [String: Any] = [
            "email": email,
            "token": token,
            "deviceId": deviceId,
            "deviceModel": deviceModel,
            "pid": pid,
            "isGuest": isGuest
        ]
        
        let req = AuthLoginAPIRequest(provider: provider, body: body)
        let dto: AuthLoginDTO = try await NetworkService.shared.requestAsync(req)
        
        guard dto.responseCode == "SUCCESS", let d = dto.data else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "Login failed"
            throw AuthRepositoryError.api(code: code, message: msg)
        }
        
        // 서버 타임스탬프가 ms 기준이라면 초단위 변환
        let accessExpSec  = Double(d.accessToken.expiredAt)
        let refreshExpSec = Double(d.refreshToken.expiredAt)
        
        await TokenService.shared.initializeTokens(
            accessToken: d.accessToken.token,
            refreshToken: d.refreshToken.token,
            accessExpiryTimestamp: accessExpSec,
            refreshExpiryTimestamp: refreshExpSec
        )
        
        return AuthEntity(
            userId: d.userId,
            email: email,
            accessToken: d.accessToken.token,
            refreshToken: d.refreshToken.token,
            accessExpiry: accessExpSec,
            refreshExpiry: refreshExpSec
        )
    }
    
    // MARK: - Snack Join
    func snackSignup(provider: AuthProvider,
                   email: String?,
                   token: String,
                   deviceId: String,
                   deviceModel: String,
                   pid: String,
                   isGuest: Bool?,
                   isAgreeMarketing: Bool,
                   isAgreePushNotification: Bool,
                   guestId: String?) async throws -> AuthJoinDataDTO {
        
        let dto: AuthJoinDTO
        
        if provider == .IOS_GUEST {
            let body: [String: Any] = [
                "email": email ?? "",
                "token": token,
                "deviceId": deviceId,
                "deviceModel": deviceModel,
                "pid": pid,
                "isGuest": true,
                "isAgreeMarketing": isAgreeMarketing,
                "isAgreePushNotification": isAgreePushNotification
            ]
            
            let req = GuestModeJoinAPIRequest(provider: provider, body: body)
            dto = try await NetworkService.shared.requestAsync(req)
        } else {
            
            let body: [String: Any] = [
                "email": email ?? "",
                "token": token,
                "deviceId": deviceId,
                "deviceModel": deviceModel,
                "pid": pid,
                "isAgreeMarketing": isAgreeMarketing,
                "isAgreePushNotification": isAgreePushNotification,
                "guestId": guestId ?? AppContext.shared.deviceUniqueID
            ]
            
            let req = AuthJoinAPIRequest(provider: provider, body: body)
            dto = try await NetworkService.shared.requestAsync(req)
        }
        
        guard dto.responseCode == "SUCCESS", let data = dto.data else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "Join failed"
            throw AuthRepositoryError.api(code: code, message: msg)
        }
        return data
    }
    
    /// 스낵 로그아웃(네트워크만 수행). 성공하면 아무것도 반환하지 않음.
    func snackLogout(refreshToken: String) async throws {
        let req = AuthLogoutAPIRequest(refreshToken: refreshToken)
        let res: LogoutResponseDTO = try await NetworkService.shared.requestAsync(req)
        
        guard res.responseCode == "SUCCESS" else {
            let code = res.errorData?.code ?? "UNKNOWN"
            let msg  = res.errorData?.defaultMessage ?? "Logout failed"
            throw AuthRepositoryError.api(code: code, message: msg)
        }
    }
    
    ///--------------

    
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
            userId: userId,
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
            AgreementEntity(title: "프로모션/마케팅 정보 수신 동의",
                            subtitle: "설정 메뉴에서 변경할 수 있습니다.",
                            agreementType: .optional),
        ]
    }
    

    func welcomeFetchAgreement() async throws -> [AgreementEntity] {
        return [
            AgreementEntity(title: "서비스 이용약관",
                            agreementType: .required),
            AgreementEntity(title: "프로모션/마케팅 정보 수신 동의",
                            agreementType: .optional),
        ]
    }
    
}
