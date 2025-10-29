//
//  LoginViewModel.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/9/25.
//

import AuthenticationServices
import SwiftyUserDefaults
import Combine

class AuthViewModel: NSObject, AuthViewModelProtocol {
    
    
    @Published var isLoginSuccess: Bool?
    
    var subscriptions = Set<AnyCancellable>()
        
    func requestAppleAuth() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = UIApplication.shared.topViewController as? ASAuthorizationControllerPresentationContextProviding
        authorizationController.performRequests()
    }
}




// 애플 로그인 델리게이트
extension AuthViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        printX("login error")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // 기본 정보 추출
            let snsID = appleIDCredential.user
            let fullName = appleIDCredential.fullName?.givenName ?? ""
            var email = appleIDCredential.email ?? ""
            
            // 만약 제공된 이메일이 없으면, JWT 토큰에서 이메일을 추출 시도
            if email.isEmpty,
               let identityToken = appleIDCredential.identityToken,
               let tokenString = String(data: identityToken, encoding: .utf8) {
                
                // JWT 디코딩을 통해 이메일 정보 추출
                email = BalconyUtil.decode(jwtToken: tokenString)["email"] as? String ?? ""
            }
            
            // 이메일이 추출되었으면 로그인 요청 실행
            if !email.isEmpty {
                requestLogin(snsType: .apple, snsID: snsID, email: email, name: fullName)
            } else {
                // 이메일 추출 실패 시, 로그인 실패 처리(필요한 경우 추가 처리)
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
    
    func requestLogin(snsType:SnsLoginType, snsID:String, email: String, name: String) {
        let parameters: [String: Any] = [
            "snsProvider": snsType.rawValue,
            "snsId": snsID,
            "email": email,
            "name": name,
            "profileImage": "",
            "pid": "",
            "ipAddress": AppContext.shared.deviceIPAddress,
            "isMailAuthTarget": false,
            "isAgreeMarketing": false,
            "isAutoLogin": false,
            "deviceId": AppContext.shared.deviceUniqueID,
            "deviceModel": AppContext.shared.deviceModelName
        ]
        
        let snsLoginRequest = SnsLoginAPIRequest(parameters: parameters)
        
        NetworkService.shared.request(snsLoginRequest)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    if snsLoginRequest.isPrintLog {
                        printX(err)
                    }
                    self.isLoginSuccess = true
                case .finished:
                    self.isLoginSuccess = true
                }
            }  receiveValue: { [weak self] (response: AuthModel) in
                printX(response)
                guard let result = response.data, let userEmail = result.email, let userID = result.userId else {
                    self?.isLoginSuccess = true
                    return
                }
                
                self?.handleLoginSuccess(userId: "\(userID)",
                                         snsID: snsID,
                                         userName: "",
                                         userEmail: userEmail,
                                         userLoginType: snsType )
                
                TokenService.shared.initializeTokens(accessToken: result.accessToken.token,
                                                     refreshToken: result.refreshToken.token,
                                                     accessExpiryTimestamp: Double(result.accessToken.expiredAt),
                                                     refreshExpiryTimestamp: Double(result.refreshToken.expiredAt))
                
                self?.isLoginSuccess = true
            }.store(in: &self.subscriptions)
    }
    
}
