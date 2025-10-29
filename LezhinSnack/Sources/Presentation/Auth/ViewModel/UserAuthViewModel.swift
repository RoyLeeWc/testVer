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
import FBSDKLoginKit

final class UserAuthViewModel: NSObject {
    
    deinit {
        printX("메모리 해제")
    }
    
    @Published var isLoginSuccess: Bool?
    @Published var needSignupFlow: (provider: AuthProvider, email: String, token: String)?

        
    var subscriptions = Set<AnyCancellable>()
    
    
    private let loginUseCase: LoginUseCaseProtocol
    private let signupUseCase: SignupUseCaseProtocol
    private let logoutUseCase: LogoutUseCaseProtocol
    
    init(loginUseCase: LoginUseCaseProtocol,
         signupUseCase: SignupUseCaseProtocol,
         logoutUseCase: LogoutUseCaseProtocol) {
        self.loginUseCase = loginUseCase
        self.signupUseCase = signupUseCase
        self.logoutUseCase = logoutUseCase
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
                guard let tokenId: String = user.idToken?.tokenString else { return }
                let name: String = profileData.name
                let email: String = profileData.email
                
                self?.login(provider: .GOOGLE, email: email, token: tokenId)
            }
        }
    }
    
    func requestFacebookAuth() {
        LoginManager().logIn(permissions: ["public_profile","email"], from: nil) { result, error in
            if let error = error {
                print("Process error: \(error)")
                return
            }
            guard let result = result else {
                print("No Result")
                return
            }
            guard let token = result.token?.tokenString else {
                print("No token")
                return
            }
            var email:String = ""
            print("token: ", result.token?.tokenString ?? "no token")
            
            GraphRequest.init(graphPath: "me", parameters: ["fields": "id, name, email, picture"])
                .start(completion: {(connection, result, error) -> Void in
                  
                    guard let fb = result as? [String: AnyObject] else { return }
                    email = fb["email"] as? String ?? ""

                    self.login(provider: .FACEBOOK, email: email, token: token)
                })
        }
    }
    
    func requestLezhinLAuth(accessToken: String) {
        self.login(provider: .LEZHIN, email: "", token: accessToken)
        
    }
    // 소셜 SDK로 token/email 획득 후 호출
    func login(provider: AuthProvider, email: String, token: String) {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            let entity = try await self.loginUseCase.executeLogin(provider: provider, email: email, token: token)
            self.isLoginSuccess = true
            
        } onError: { [weak self] error in
            if case let AuthRepositoryError.api(code, _) = error,
               code == LZSConstant.NotFoundUser {
                self?.needSignupFlow = (provider, email, token) // 약관 후 회원가입으로
            } else {
                self?.isLoginSuccess = false
            }
        }
    }
    
    
    
    // 약관 동의 후 회원가입 → 재로그인
    func signupThenLogin(provider: AuthProvider,
                         email: String,
                         token: String,
                         agreeMarketing: Bool,
                         agreePush: Bool) {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            _ = try await self.signupUseCase.executeSignup(provider: provider,
                                                           email: email,
                                                           token: token,
                                                           pid: UIDevice.current.identifierForVendor?.uuidString ?? "",
                                                           isAgreeMarketing: agreeMarketing,
                                                           isAgreePushNotification: agreePush,
                                                           guestId: AppContext.shared.deviceUniqueID)
            
            let entity = try await self.loginUseCase.executeLogin(provider: provider, email: email, token: token)
            self.isLoginSuccess = true
        } onError: { [weak self] _ in
            self?.isLoginSuccess = false
        }
    }
    
    // 로그아웃
        @Published var isLogoutSuccess: Bool?
        func requestLogout() {
            if Defaults.userLoginType != AuthProvider.IOS_GUEST.rawValue {
                let refreshToken = TokenService.shared.refreshToken
                guard !refreshToken.isEmpty else {
                    isLogoutSuccess = false
                    return
                }
                LZSnackConcurrencyManager.run { [weak self] in
                    try await self?.logoutUseCase.executeLogout(refreshToken: refreshToken)
                    self?.isLogoutSuccess = true
                } onError: { [weak self] _ in
                    self?.isLogoutSuccess = false
                }
            }
        }
}


// 애플 로그인 델리게이트
extension UserAuthViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        printX("login error")
    }
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard let cred = authorization.credential as? ASAuthorizationAppleIDCredential else {
            isLoginSuccess = false
            return
        }
        
        // 1) 토큰(JWT) 필수
        guard let tokenData = cred.identityToken,
              let idToken = String(data: tokenData, encoding: .utf8) else {
            isLoginSuccess = false
            return
        }
        
        // 2) 이메일: 최초 로그인 아니면 Apple이 안 줄 수 있음 → JWT에서 디코딩
        var email = cred.email ?? ""
        if email.isEmpty {
            email = (LZSUtil.decode(jwtToken: idToken)["email"] as? String) ?? ""
        }
        guard !email.isEmpty else {
            isLoginSuccess = false
            return
        }
        
        self.login(provider: .APPLE, email: email, token: idToken)
    }
}
