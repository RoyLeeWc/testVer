//
//  WithdrawViewModel.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/22/25.
//


import Combine
import SwiftyUserDefaults

final class WithdrawViewModel {
    
    @Published var isLogoutSuccess: Bool?
    
    private let authUseCase: AuthUseCaseProtocol
    
    init(authUseCase: AuthUseCaseProtocol) {
        self.authUseCase = authUseCase
    }
    
    
    func requestLogout() {
        if Defaults.userLoginType != SnsLoginType.guestMode.rawValue {
            Task {
                do {
                    try await authUseCase.executeLogoutAndLoginGuestMode()
                    await MainActor.run {
                        self.isLogoutSuccess = true
                    }
                } catch {
                    await MainActor.run {
                        self.isLogoutSuccess = false
                    }
                }
            }
        }
    }
    
}
