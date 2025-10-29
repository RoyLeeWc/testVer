//
//  LogoutUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 9/9/25.
//
import SwiftyUserDefaults
import Foundation

protocol LogoutUseCaseProtocol {
    /// 서버 로그아웃(PUT) + 로컬 세션 정리
    func executeLogout(refreshToken: String) async throws
}

final class LogoutUseCase: LogoutUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    init(authLogoutRepository: AuthRepositoryProtocol) { self.repository = authLogoutRepository }

    
    func executeLogout(refreshToken: String) async throws {
        try await repository.snackLogout(refreshToken: refreshToken)
        
        await TokenService.shared.clearAll()
    }
}
