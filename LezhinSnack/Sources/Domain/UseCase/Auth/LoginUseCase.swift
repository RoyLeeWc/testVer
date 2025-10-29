//
//  LoginUseCase.swift
//  LezhinSnack
//
//  Created by 이우찬 on 9/9/25.
//
import SwiftyUserDefaults
import Foundation
import UIKit

protocol LoginUseCaseProtocol {
    /// token: 소셜 idToken 또는 앱의 AccessToken(스플래시 자동로그인)
    func executeLogin(provider: AuthProvider, email: String, token: String) async throws -> AuthEntity
}

final class LoginUseCase: LoginUseCaseProtocol {

    
    private let repository: AuthRepositoryProtocol
    init(authRepository: AuthRepositoryProtocol) {
        self.repository = authRepository
    }
    
    func executeLogin(provider: AuthProvider, email: String, token: String) async throws -> AuthEntity {
        let entity = try await repository.snackLogin(
            provider: provider,
            email: email,
            token: token,
            deviceId: AppContext.shared.deviceUniqueID,
            deviceModel: AppContext.shared.deviceModelName,
            pid: UIDevice.current.identifierForVendor?.uuidString ?? "",
            isGuest: true
        )
        await handleLoginSuccess(
            userId: entity.userId,
            userLoginType: provider
        )
        return entity
    }
    
    func handleLoginSuccess(
        userId: Int,
        userLoginType: AuthProvider
    ) async {
        Defaults.userId = userId
        Defaults.userLoginType = userLoginType.rawValue
        
        if userLoginType != .IOS_GUEST {
            Defaults.lastLoginType = userLoginType.rawValue
        }
        
        printX("\(userLoginType.rawValue) 으로 로그인 성공 snsId: \(Defaults.snsId)",isBoxMode: true)
        
        NotificationCenter.default.post(name: .LZSChangeAccountNotification, object: nil)
    }
}
