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

protocol SplashViewModelDelegate: AnyObject {
    /// 강제 업데이트 안내
    func showRequisiteUpdate(title: String, message: String, downloadURL: String, version: String)
    /// 권장 업데이트 안내
    func showOptionalUpdate(title: String, message: String, downloadURL: String, version: String)
}

class SplashViewModel {
    
    deinit {
        printX("메모리 해제")
    }
    
    @Published var isLoginProcessOver: Bool?
    @Published var isAppVerCheckProcessOver: Bool?
    
 
    private let loginUseCase: LoginUseCaseProtocol
    private let appVersionUseCase: AppVersionUseCaseProtocol
    private let signupUseCase: SignupUseCaseProtocol
    
    
    weak var delegate: SplashViewModelDelegate?
    
    init(appVersionUseCase: AppVersionUseCaseProtocol, loginUseCase: LoginUseCaseProtocol, signupUseCase: SignupUseCaseProtocol) {
        
        self.appVersionUseCase = appVersionUseCase
        self.loginUseCase = loginUseCase
        self.signupUseCase = signupUseCase
    }
    
    func requestLogin() {
        if Defaults.userLoginType != AuthProvider.IOS_GUEST.rawValue {
            isLoginProcessOver = true
        } else {
            requestGuestModeLogin()
        }
    }
    
    func requestAppVerCheck() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            let current = LZSUtil.getAppVersion()
            
            let dto = try await self.appVersionUseCase.executeCheck(currentVersion: current)
            
            // UI 이벤트는 메인에서
            await MainActor.run {
                guard let data = dto?.data else {
                    return }
                
                if data.isForceUpdate ?? false {
                    self.delegate?.showRequisiteUpdate(
                        title: data.title ?? "",
                        message: data.description ?? "",
                        downloadURL: data.downloadUrl ?? "",
                        version: data.version ?? ""
                    )
                    return
                }
                
                if data.isNewAppVersion ?? false {
                    self.delegate?.showOptionalUpdate(
                        title: data.title ?? "",
                        message: data.description ?? "",
                        downloadURL: data.downloadUrl ?? "",
                        version: data.version ?? ""
                    )
                }
                self.isAppVerCheckProcessOver = true
            }
        } onError: { _ in
            // 실패는 통과 정책이면 아무 것도 안 함
        }
    }
    
    // 2) 로그인 공통 함수
    func loginGuest(with guestId: String) {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            try await self.loginUseCase.executeLogin(
                provider: .IOS_GUEST,   //
                email: "",
                token: guestId
            )
            await MainActor.run { self.isLoginProcessOver = true }
        } onError: { [weak self] error in
            self?.isLoginProcessOver = false
        }
    }
    
    
    func requestGuestModeLogin() {
        if !Defaults.isGuestSignUpStatus {
            LZSnackConcurrencyManager.run { [weak self] in
                try await self?.signupUseCase.executeSignup(provider: .IOS_GUEST,
                                                            email: "",
                                                            token: LZSUtil.retrieveUniqueDeviceIdentifier(),
                                                            pid: UIDevice.current.identifierForVendor?.uuidString ?? "",
                                                            isAgreeMarketing: Defaults.isAgreeMarketing,
                                                            isAgreePushNotification: Defaults.isAgreePushNotification,
                                                            guestId: nil)
                // 가입 성공 → 로그인
                await MainActor.run {
                    Defaults.isGuestSignUpStatus = true
                    self?.loginGuest(with: Defaults.guestModeId)
                    
                }
            } onError: { [weak self] error in
                guard let self else { return }
                // 서버가 던진 코드가 DUPLICATE_USER면 이미 가입된 사용자 → 로그인 시도
                if case let AuthRepositoryError.api(code, _) = error, code == "DUPLICATE_USER" || code == "NOT_FOUND_USER"{
                    loginGuest(with: Defaults.guestModeId)
                } else {
                    self.isLoginProcessOver = false
                    Defaults.guestModeId = ""
                    Defaults.isGuestSignUpStatus = false
                }
            }
        } else {
            loginGuest(with: Defaults.guestModeId)
        }
    }
}
