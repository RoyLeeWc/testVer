//
//  WithdrawViewModel.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/22/25.
//


import Combine
import SwiftyUserDefaults
import UIKit

final class WithdrawViewModel {
    
    @Published var isLogoutSuccess: Bool?
    @Published var reasons: [WithdrawalReasonEntity] = []   // 탈퇴사유목록 데이터
    @Published var isWithdrawing: Bool = false
    @Published var withdrawSuccess: Bool?
    @Published var withdrawError: String?
    @Published var hasActiveSubscription: Bool?        // 구독 활성 여부
    @Published var subscriptionError: String?
    
    
    private let withdrawalReasonsUseCase: WithdrawalReasonsUseCaseProtocol
    private let withdrawUseCase: WithdrawUseCaseProtocol
    private let mySubscriptionUseCase: MySubscriptionUseCaseProtocol
    private let signupUseCase: SignupUseCaseProtocol
    private let loginUseCase: LoginUseCaseProtocol
    
    // 내부 기타 로컬 임시 기타 아이디
    static let localOtherId = -1
    
    private let otherCategoryServerId: Int? = -1 // ← 팀 합의값으로 교체(없으면 nil)
    
    
    init(withdrawalReasonsUseCase: WithdrawalReasonsUseCaseProtocol,
         withdrawUseCase: WithdrawUseCaseProtocol,
         mySubscriptionUseCase: MySubscriptionUseCaseProtocol,
         signupUseCase: SignupUseCaseProtocol,
         loginUseCase: LoginUseCaseProtocol) {
        self.withdrawalReasonsUseCase = withdrawalReasonsUseCase
        self.withdrawUseCase = withdrawUseCase
        self.mySubscriptionUseCase = mySubscriptionUseCase
        self.signupUseCase = signupUseCase
        self.loginUseCase = loginUseCase
    }
    
    func fetchWithdrawalReasons() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            let list = try await self.withdrawalReasonsUseCase.fetchWithdrawalReasons()
            let sorted = list.sorted { $0.orderNumber < $1.orderNumber }
            
            // 서버 목록에 "기타"가 있는지 검사(한/영 대응)
            let hasOther = sorted.contains {
                let t = $0.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                return t == "기타" || t == "other"
            }
            
            // 없으면 로컬 "기타" 추가
            if hasOther {
                self.reasons = sorted
            } else {
                let lastOrder = (sorted.last?.orderNumber ?? 0)
                let localOther = WithdrawalReasonEntity(
                    withdrawalCategoryId: Self.localOtherId,
                    orderNumber: lastOrder + 1,
                    languageType: LZSUtil.getPrimaryLanguageCode(),
                    title: "기타"
                )
                self.reasons = sorted + [localOther]
            }
        }
    }
    
    func checkSubscription() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            let info = try await self.mySubscriptionUseCase.executeFetchMySubscription()
            self.hasActiveSubscription = info?.isActive ?? false
        } onError: { [weak self] error in

            self?.subscriptionError = "구독 상태를 확인할 수 없어요. 잠시 후 다시 시도해 주세요."
            // 에러 시엔 보수적으로 미구독(false) 취급하거나, nil로 두고 VC에서 분기해도 됨
            self?.hasActiveSubscription = false
        }
    }
    
    // 게스트: 가입이 필요하면 가입하고(이미 가입: DUPLICATE_USER면 무시), 바로 로그인까지 끝냄
    // 실패 시 throw로 올림
    func performGuestJoinThenLogin() async throws {
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
    
    func requestWithdrawal(selectedReasonId: Int?, reasonText: String?) {
        // 입력 검증은 여기서 끝내 VC는 단순 호출만
        guard let selId = selectedReasonId else {
            withdrawError = "탈퇴 사유를 선택해 주세요"
            return
        }
        
        // 기타 판단
        let isOther: Bool = {
            if selId == Self.localOtherId { return true }
            if let item = reasons.first(where: { $0.withdrawalCategoryId == selId }) {
                let t = item.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                return t == "기타" || t == "other"
            }
            return false
        }()
        
        // 실제 전송할 categoryId
        let effectiveCategoryId: Int? = {
            if isOther {
                return -1 // 합의값이 없으면 nil
            } else {
                return selId
            }
        }()
        
        guard let categoryId = effectiveCategoryId else {
            withdrawError = "기타 사유 전송이 현재 불가합니다. 잠시 후 다시 시도해 주세요."
            return
        }
        
        let trimmedReason = (reasonText ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if isOther {
            guard trimmedReason.count > 10 else {
                withdrawError = "기타 사유를 10자 이상 입력해 주세요"
                return
            }
        }
        
        isWithdrawing = true
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            // 1) 회원탈퇴 호출
            _ = try await self.withdrawUseCase.withdraw(categoryId: categoryId, reason: isOther ? trimmedReason : "")
            
            // 2) 후처리: 토큰/Defaults 정리
            await TokenService.shared.clearAll()
            
            // 옵션: 즉시 게스트 로그인 (앱 사용 지속)
            // 4) 게스트 로그인 시도
            try await performGuestJoinThenLogin()
            
            // 5) 성공 플래그 (UI 업데이트는 MainActor)
            await MainActor.run {
                self.withdrawSuccess = true
                self.isWithdrawing = false
            }
            
        } onError: { [weak self] error in
            guard let self else { return }
            self.isWithdrawing = false
            
            if case let UserRepositoryError.api(code, msg) = error {
                // 서버가 주던 에러 케이스 반영: WITHDRAW_USER 등
                if code == "WITHDRAW_USER" {
                    self.withdrawError =  msg.isEmpty ? "이미 탈퇴된 계정입니다." : msg
                } else {
                    self.withdrawError = msg.isEmpty ? "탈퇴에 실패했어요. 잠시 후 다시 시도해 주세요." : msg
                }
            } else {
                self.withdrawError = "탈퇴에 실패했어요. 네트워크 상태를 확인해 주세요."
            }
        }
    }
    
    func requestLogout() {
        
        if Defaults.userLoginType != AuthProvider.IOS_GUEST.rawValue {
            Task {
                do {
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
