//
//  ProfileViewModel.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/8/25.
//

import SwiftyUserDefaults
import Combine
import UIKit

final class MyPageViewModel {
    
    
    @Published var isLogoutSuccess: Bool?
    @Published var userCoinEntity: UserCoinEntity?
    
    private let mySubscriptionUseCase: MySubscriptionUseCaseProtocol

    @Published var subscriptionInfo: MySubscriptionInfoEntity?
    @Published var membershipState: LZSnackMembershipState = .neverSubscribed
    @Published var subscriptionError: String?
    
    deinit {
        printX("메모리 해제")
    }
    
    private let userUseCase: UserUseCaseProtocol
    private let logoutUseCase: LogoutUseCaseProtocol
    private let updateNicknameUseCase: UpdateNicknameUseCaseProtocol
    private let userInfoUseCase: UserInfoUseCaseProtocol
    private let signupUseCase: SignupUseCaseProtocol
    private let loginUseCase: LoginUseCaseProtocol
    
    
    /// 업데이트닉네임
    @Published var updatedNickname: String?
    /// 닉네임 변경실패
    @Published var updateNicknameError: String?
    /// Userinfo UI 바인딩용
    @Published var userInfo: UserInfoEntity?
    
    init(userUseCase: UserUseCaseProtocol,
         logoutUseCase: LogoutUseCaseProtocol,
         updateNicknameUseCase: UpdateNicknameUseCaseProtocol,
         userInfoUseCase: UserInfoUseCaseProtocol,
         signupUseCase: SignupUseCaseProtocol,
         loginUseCase: LoginUseCaseProtocol,
         mySubscriptionUseCase: MySubscriptionUseCaseProtocol) {
        
        self.userUseCase = userUseCase
        self.logoutUseCase = logoutUseCase
        self.updateNicknameUseCase = updateNicknameUseCase
        self.userInfoUseCase = userInfoUseCase
        self.signupUseCase = signupUseCase
        self.loginUseCase = loginUseCase
        self.mySubscriptionUseCase = mySubscriptionUseCase
       
    }
    
    func checkSubscription() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            
            // data == null → 미구독
            let entity = try await self.mySubscriptionUseCase.executeFetchMySubscription()
            guard let entity else {
                self.subscriptionInfo = nil
                self.membershipState = .neverSubscribed
                return
            }
            
            self.subscriptionInfo = entity
            self.membershipState = self.mapState(from: entity)
            
        } onError: { [weak self] error in
            self?.subscriptionError = "구독 상태를 확인할 수 없어요. 잠시 후 다시 시도해 주세요."
            self?.subscriptionInfo = nil
            self?.membershipState = .neverSubscribed
        }
    }
    
    private func mapState(from info: MySubscriptionInfoEntity) -> LZSnackMembershipState {
        switch info.periodType {
        case .monthly:
            return info.isActive ? .monthlySubscriptionActive : .monthlySubscriptionCancelled
        case .annual:
            return info.isActive ? .annualSubscriptionActive : .annualSubscriptionCancelled
        case .oneTime, .unknown:
            return .neverSubscribed
        }
    }
    
    // 게스트: 가입이 필요하면 가입하고(이미 가입: DUPLICATE_USER면 무시), 바로 로그인까지 끝냄
    // 실패 시 throw로 올림
    private func performGuestJoinThenLogin() async throws {
        // 1) guestId 준비/보존
        var guestId = LZSUtil.retrieveUniqueDeviceIdentifier()
        
        Defaults.guestModeId = guestId
        // 2) 가입 시도 (iOS_GUEST의 token == guestId, isGuest=true)
        do {
            _ = try await signupUseCase.executeSignup(
                provider: .IOS_GUEST,
                email: "",
                token: guestId,
                pid: UIDevice.current.identifierForVendor?.uuidString ?? "",
                isAgreeMarketing: Defaults.isAgreeMarketing,
                isAgreePushNotification: Defaults.isAgreePushNotification,
                guestId: nil // iOS_GUEST는 guestId 필드 사용 X (문서 기준)
            )
        } catch let AuthRepositoryError.api(code, _) where code == "DUPLICATE_USER" {
            // 이미 가입됨 → 무시하고 로그인 진행
        }
        // 3) 로그인
        try await loginUseCase.executeLogin(
            provider: .IOS_GUEST,
            email: "",
            token: guestId
        )
    }
    
    
    func requestLogout() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self = self else { return }
            // 1) 리프레시 토큰 확인
            let refreshToken = TokenService.shared.refreshToken
            guard !refreshToken.isEmpty else {
                self.isLogoutSuccess = false
                return
            }
            // 2) 게스트가 아닌 경우에만 로그아웃 + 게스트 로그인
            guard Defaults.userLoginType != AuthProvider.IOS_GUEST.rawValue else {
                self.isLogoutSuccess = false
                return
            }
            // 3) 서버 로그아웃
            try await logoutUseCase.executeLogout(refreshToken: refreshToken)
            
            // 4) 게스트 로그인 시도
            try await self.performGuestJoinThenLogin()
            
            // 5) 성공 플래그 (UI 업데이트는 MainActor)
            await MainActor.run { self.isLogoutSuccess = true }
            
        } onError: { [weak self] error in
            self?.isLogoutSuccess = false
        }
    }
    
    func fetchUserCoinBalance() {
        LZSnackConcurrencyManager.run {
            self.userCoinEntity = try await self.userUseCase.executeFetchUserCoin()
        }
    }
    
    func fetchUserInfo() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            let info = try await self.userInfoUseCase.fetchUserInfo()
            Defaults.userLoginType = info.joinType.rawValue
            Defaults.userId = info.userId
            self.userInfo = info
            
        } onError: { [weak self] _ in
            // 필요 시 에러 처리/토스트 등
            self?.userInfo = nil
        }
    }
    
    
    func updateNickname(_ newNickname: String) {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            do {
                let res = try await self.updateNicknameUseCase.updateNickname(newNickname)
                self.updatedNickname = res.nickname
            } catch let UserRepositoryError.api(code, message) {
                self.updateNicknameError = message.isEmpty ? code : message
            } catch {
                self.updateNicknameError = "닉네임 변경 실패"//
            }
        }
    }
    
    
}
