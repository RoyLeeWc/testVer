//
//  ProfileViewModel.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/8/25.
//

import SwiftyUserDefaults
import Combine

final class MyPageViewModel {
    
    
    @Published var isLogoutSuccess: Bool?
    @Published var userCoinEntity: UserCoinEntity?
    
    deinit {
        printX("메모리 해제")
    }
    
    private let authUseCase: AuthUseCaseProtocol
    private let userUseCase: UserUseCaseProtocol
    
    init(authUseCase: AuthUseCaseProtocol,
         userUseCase: UserUseCaseProtocol) {
        self.authUseCase = authUseCase
        self.userUseCase = userUseCase
    }
    
    
    func requestLogout() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self = self else { return }
            if Defaults.userLoginType != SnsLoginType.guestMode.rawValue {
                try await authUseCase.executeLogoutAndLoginGuestMode()
                self.isLogoutSuccess = true
            } else {
                self.isLogoutSuccess = false
            }
        } onError: { [weak self] error in
            self?.isLogoutSuccess = false
        }
    }
    
    func fetchUserCoinBalance() {
        LZSnackConcurrencyManager.run {
            self.userCoinEntity = try await self.userUseCase.executeFetchUserCoinBalance()
        }
    }
    
    
    
    
}
