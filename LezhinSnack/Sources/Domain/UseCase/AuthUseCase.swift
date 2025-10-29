//
//  LoginUserCase.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/10/25.
//

import SwiftyUserDefaults
import Foundation


protocol AuthUseCaseProtocol {
    /// 게스트 모드 로그인
    func executeGuestLogin() async throws -> AuthEntity
    
    /// 마지막 로그인 정보로 로그인
    func executeLoginWithLastData() async throws -> AuthEntity
    
    /// SNS 계정 로그아웃 후 게스트모드로 재 로그인
    func executeLogoutAndLoginGuestMode() async throws -> AuthEntity
    
    /// SNS 계정으로 로그인
    func executeLogin(snsType: SnsLoginType, snsID: String, email: String, name: String) async throws -> AuthEntity
    
    /// 이용약관 데이터 가져오기
    func executeFetchAgreementList() async throws -> [AgreementEntity]
}

class AuthUseCase: AuthUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol) {
        self.repository = authRepository
    }
    
    func executeLogin(snsType: SnsLoginType, snsID: String, email: String, name: String) async throws -> AuthEntity {
        let parameters: [String: Any] = [
            "snsProvider": snsType.rawValue,
            "snsId": snsID,
            "email": email,
            "name": name,
            "profileImage": "",
            "pid": "",
            "ipAddress": AppContext.shared.deviceIPAddress,
            "isMailAuthTarget": false,
            "isAgreeMarketing": false,
            "isAutoLogin": false,
            "deviceId": AppContext.shared.deviceUniqueID,
            "deviceModel": AppContext.shared.deviceModelName
        ]
        
        let authEntity = try await repository.login(parameters: parameters)
        
        await handleLoginSuccess(userId: authEntity.userId,
                                 snsID: snsID,
                                 userName: name,
                                 userEmail: authEntity.email,
                                 userLoginType: snsType )
        
        return authEntity

    }
    
    func executeLogoutAndLoginGuestMode() async throws -> AuthEntity {
        let logoutParameters: [String: Any] = [
            "refreshToken": Defaults.refreshToken
        ]
        
        let guestModeParameters: [String: Any] = [
            "snsProvider": SnsLoginType.guestMode.rawValue,
            "snsId": AppContext.shared.deviceUniqueID,
            "email": "\(AppContext.shared.deviceUniqueID)@apple_guest.com",
            "name": "",
            "profileImage": "",
            "pid": "",
            "ipAddress": AppContext.shared.deviceIPAddress,
            "isMailAuthTarget": false,
            "isAgreeMarketing": false,
            "isAutoLogin": false,
            "deviceId": AppContext.shared.deviceUniqueID,
            "deviceModel": AppContext.shared.deviceModelName
        ]
        
        
        let authEntity = try await repository.logoutAndLoginGuestMode(logoutParameters: logoutParameters, guestModeParameters: guestModeParameters)
        
        await handleLoginSuccess(userId: authEntity.userId,
                                 snsID: Defaults.guestModeId,
                                 userName: "",
                                 userEmail: authEntity.email,
                                 userLoginType: .guestMode )
        
        return authEntity
    }
    
    func executeGuestLogin() async throws -> AuthEntity {
        let parameters: [String: Any] = [
            "snsProvider": SnsLoginType.guestMode.rawValue,
            "snsId": AppContext.shared.deviceUniqueID,
            "email": "\(AppContext.shared.deviceUniqueID)@apple_guest.com",
            "name": "",
            "profileImage": "",
            "pid": "",
            "ipAddress": AppContext.shared.deviceIPAddress,
            "isMailAuthTarget": false,
            "isAgreeMarketing": false,
            "isAutoLogin": false,
            "deviceId": AppContext.shared.deviceUniqueID,
            "deviceModel": AppContext.shared.deviceModelName
        ]
        let authEntity = try await repository.loginGuest(parameters: parameters)
        
        await handleLoginSuccess(userId: authEntity.userId,
                                 snsID: Defaults.guestModeId,
                                 userName: "",
                                 userEmail: authEntity.email,
                                 userLoginType: .guestMode )
        
        return authEntity
    }
    
    func executeLoginWithLastData() async throws -> AuthEntity {
        let parameters: [String: Any] = [
            "snsProvider": Defaults.userLoginType,
            "snsId": Defaults.snsId,
            "email": Defaults.userEmail,
            "name": Defaults.userName,
            "profileImage": "",
            "pid": "",
            "ipAddress": AppContext.shared.deviceIPAddress,
            "isMailAuthTarget": false,
            "isAgreeMarketing": false,
            "isAutoLogin": false,
            "deviceId": AppContext.shared.deviceUniqueID,
            "deviceModel": AppContext.shared.deviceModelName
        ]
        let authEntity = try await repository.loginWithSavedData(parameters: parameters)
        
        await handleLoginSuccess(userId: authEntity.userId,
                                 snsID: Defaults.snsId,
                                 userName: Defaults.userName,
                                 userEmail: authEntity.email,
                                 userLoginType: SnsLoginType(rawValue: Defaults.userLoginType) ?? SnsLoginType.etc )
        
        return authEntity
    }
    
    func handleLoginSuccess(
        userId: String,
        snsID: String,
        userName: String,
        userEmail: String,
        userLoginType: SnsLoginType
    ) async {
        Defaults.snsId = snsID
        Defaults.userId = userId
        Defaults.userName = userName
        Defaults.userEmail = userEmail
        Defaults.userLoginType = userLoginType.rawValue
        
        if userLoginType != .guestMode {
            Defaults.lastLoginType = userLoginType.rawValue
        }
        
        printX("\(userLoginType.rawValue) 으로 로그인 성공 snsId: \(Defaults.snsId)",isBoxMode: true)
        
        NotificationCenter.default.post(name: .LZSChangeAccountNotification, object: nil)
    }
    
    func executeFetchAgreementList() async throws -> [AgreementEntity] {
        return try await repository.fetchAgreement()
    }
    
}
