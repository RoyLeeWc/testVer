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
    /// 이용약관 데이터 가져오기
    func executeFetchAgreementList() async throws -> [AgreementEntity]
    /// 신규이용약관 데이터 가져오기
    func executeWelcomeFetchAgreementList() async throws -> [AgreementEntity]
}

class AuthUseCase: AuthUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol) {
        self.repository = authRepository
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

    
    func handleLoginSuccess(
        userId: Int,
        snsID: String,
        userName: String,
        userEmail: String,
        userLoginType: SnsLoginType
    ) async {
        Defaults.snsId = snsID
        Defaults.userId = userId
        Defaults.userName = userName
        Defaults.userEmail = userEmail
        Defaults.userLoginType = AuthProvider.IOS_GUEST.rawValue
        
        if userLoginType != .guestMode {
            Defaults.lastLoginType = AuthProvider.IOS_GUEST.rawValue
        }
        
        printX("\(userLoginType.rawValue) 으로 로그인 성공 snsId: \(Defaults.snsId)",isBoxMode: true)
        
        NotificationCenter.default.post(name: .LZSChangeAccountNotification, object: nil)
    }
    
    func executeFetchAgreementList() async throws -> [AgreementEntity] {
        return try await repository.fetchAgreement()
    }
    
    func executeWelcomeFetchAgreementList() async throws -> [AgreementEntity] {
        return try await repository.welcomeFetchAgreement()
    }
    
    
}
