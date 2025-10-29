//
//  SignupUseCase.swift
//  LezhinSnack
//
//  Created by 이우찬 on 9/9/25.
//

import Foundation
import UIKit
import SwiftyUserDefaults

protocol SignupUseCaseProtocol {
    func executeSignup(provider: AuthProvider,
                       email: String?,
                       token: String,                  // SNS=JWT, Guest=guestUUID
                       pid: String?,                   
                       isAgreeMarketing: Bool,
                       isAgreePushNotification: Bool,
                       guestId: String?) async throws -> AuthJoinDataDTO
}

final class SignupUseCase: SignupUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    init(authRepository: AuthRepositoryProtocol) {
        self.repository = authRepository
    }

    func executeSignup(provider: AuthProvider,
                       email: String?,
                       token: String,                  // SNS=JWT, Guest=guestUUID
                       pid: String?,
                       isAgreeMarketing: Bool,
                       isAgreePushNotification: Bool,
                       guestId: String?) async throws -> AuthJoinDataDTO {
        let entity = try await repository.snackSignup(
            provider: provider,
            email: email,
            token: token,
            deviceId: AppContext.shared.deviceUniqueID,
            deviceModel: AppContext.shared.deviceModelName,
            pid: pid ?? "",
            isGuest: true,
            isAgreeMarketing: isAgreeMarketing,
            isAgreePushNotification: isAgreePushNotification,
            guestId: guestId
        )
        await handleLoginSuccess(
            userId: entity.userId,
            userLoginType: provider,
            userEmail: entity.email
        )
        return entity
    }
}

func handleLoginSuccess(
    userId: Int,
    userLoginType: AuthProvider,
    userEmail: String,
    
) async {

    Defaults.userId = userId
    Defaults.userLoginType = userLoginType.rawValue
    Defaults.userEmail = userEmail
    
    if userLoginType != .IOS_GUEST {
        Defaults.lastLoginType = userLoginType.rawValue
    }
  
}
