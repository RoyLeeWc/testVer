//
//  SplashViewModel.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/8/25.
//

import Combine
import SwiftyUserDefaults
import UIKit
import Toast

class SplashViewModel {
    
    deinit {
        printX("메모리 해제")
    }
    
    @Published var isLoginProcessOver: Bool?
    
    private let authUseCase: AuthUseCaseProtocol
    
    init(authUseCase: AuthUseCaseProtocol) {
        self.authUseCase = authUseCase
    }
    
    func requestLogin() {
//        isLoginProcessOver = true
        if Defaults.userLoginType != SnsLoginType.guestMode.rawValue {
            requestLoginWithLastLoginData()
        } else {
            requestGuestModeLogin()
        }
    }
    
    func requestGuestModeLogin() {
        LZSnackConcurrencyManager.run { [weak self] in
            try await self?.authUseCase.executeGuestLogin()
            self?.isLoginProcessOver = true
        } onError: { [weak self] error in
            let message = "게스트 모드 로그인에 실패 했습니다."
            self?.isLoginProcessOver = true
        }
    }
    
    
    func requestLoginWithLastLoginData() {
        LZSnackConcurrencyManager.run { [weak self] in
            try await self?.authUseCase.executeLoginWithLastData()
            self?.isLoginProcessOver = true
        } onError: { [weak self] error in
            self?.requestGuestModeLoginFaildWidthLastLogin()
        }
    }
    
    func requestGuestModeLoginFaildWidthLastLogin() {
        LZSnackConcurrencyManager.run { [weak self] in
            try await self?.authUseCase.executeGuestLogin()
            let message = "게스트 모드 로그인에 실패 했습니다."
            self?.isLoginProcessOver = true
            
            await MainActor.run {
                
                let popup = LZSnackAlertPopupView(
                    width: 320,
                    height: 222,
                    title: "[4개국어 언어 적용 요망] 이전에 로그인 한 회원정보로 로그인에 실패 했습니다.",
                    message: "\n로그인 타입 : \(Defaults.userLoginType)\n로그인 이메일 : \(Defaults.userEmail)",
                    buttonTitle: "다시 시도하기",
                    handler: {  }
                )
                popup.show()
            }
        }
    }
}
