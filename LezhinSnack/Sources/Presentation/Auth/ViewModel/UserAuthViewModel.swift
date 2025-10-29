//
//  LoginViewModel.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/9/25.
//

import AuthenticationServices
import SwiftyUserDefaults
import Combine
import Alamofire
import GoogleSignIn
import FirebaseCore

final class UserAuthViewModel: NSObject {
    
    deinit {
        printX("메모리 해제")
    }
    
    @Published var isLoginSuccess: Bool?
    
    var subscriptions = Set<AnyCancellable>()
    
    private let authUseCase: AuthUseCaseProtocol
    
    init(authUseCase: AuthUseCaseProtocol) {
        self.authUseCase = authUseCase
    }
        
    func requestAppleAuth() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = UIApplication.shared.topViewController as? ASAuthorizationControllerPresentationContextProviding
        authorizationController.performRequests()
    }
    
    func requestGoogleAuth() {
        
        guard let viewController = UIApplication.shared.topViewController else { return }
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration.init(clientID: FirebaseApp.app()?.options.clientID ?? "" )
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { [weak self] result, error in
            guard error == nil else { printX(error,isBoxMode: true)
                return
            }
            
            guard let user = result?.user else { return }

            if let profileData = user.profile {
                guard let snsID = user.userID else { return }
                let name: String = profileData.name
                let email: String = profileData.email
                
                self?.requestLogin(snsType: .google, snsID: snsID, email: email, name: name)
                
            }
        }
    }
    
    func requestLogin(snsType: SnsLoginType, snsID: String, email: String, name: String) {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            let loginResult = try await authUseCase.executeLogin(snsType: snsType, snsID: snsID, email: email, name: name)
            self.isLoginSuccess = true
        } onError: { [weak self] error in
            self?.isLoginSuccess = false
        }
    }
    
    func requestLogout() {
        if Defaults.userLoginType != SnsLoginType.guestMode.rawValue {
            LZSnackConcurrencyManager.run { [weak self] in
                guard let self else { return }
                try await authUseCase.executeLogoutAndLoginGuestMode()
                self.isLoginSuccess = true
            } onError: { [weak self] error in
                self?.isLoginSuccess = false
            }
        }
    }
}


// 애플 로그인 델리게이트
extension UserAuthViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        printX("login error")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let snsID = appleIDCredential.user
            
            // Keychain을 이용한 fullName 저장 및 조회
            var fullName = appleIDCredential.fullName?.givenName ?? ""
            let service = "com.kidarisstudio.appleLogin"
            let account = "fullName"
            
            if fullName.isEmpty {
                // 로그인 재시도 시, Keychain에 저장된 fullName 조회
                if let storedData = KeychainService.shared.read(service: service, account: account),
                   let storedName = String(data: storedData, encoding: .utf8) {
                    fullName = storedName
                }
            } else {
                // 최초 로그인 시, fullName을 Keychain에 저장
                if let data = fullName.data(using: .utf8) {
                    _ = KeychainService.shared.save(data, service: service, account: account)
                }
            }
            
            var email = appleIDCredential.email ?? ""
            // 제공된 이메일이 없을 경우 JWT 토큰에서 추출 시도
            if email.isEmpty,
               let identityToken = appleIDCredential.identityToken,
               let tokenString = String(data: identityToken, encoding: .utf8) {
                email = LZSUtil.decode(jwtToken: tokenString)["email"] as? String ?? ""
            }
            
            if !email.isEmpty {
                requestLogin(snsType: .apple, snsID: snsID, email: email, name: fullName)
            } else {
                isLoginSuccess = false
            }
            
        case let passwordCredential as ASPasswordCredential:
            // iCloud Keychain을 사용한 로그인 (기존 로직 그대로)
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            isLoginSuccess = false
            
        default:
            isLoginSuccess = false
        }
    }
}
