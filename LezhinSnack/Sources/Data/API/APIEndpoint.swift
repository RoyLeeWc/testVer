//
//  APIEndpoint.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/2/25.
//


enum APIEndpoint: String {
    
    /// 게스트 모드 로그인
    case guestModeLogin     = "/api/balcony-api/auth/login"
    
    /// SNS 로그인
    case snsLogin     = "/api/balcony-api/auth/sign-in"
    
    /// SNS 회원가입
    case snsSignUp     = "/api/balcony-api/auth/sign-up"
    
    /// 로그아웃
    case logout = "/api/balcony-api/auth/logout"
    
    /// 토큰 리프레쉬
    case refreshAccessToken = "/api/balcony-api/auth/refresh"
    
    ///검색
    case search = "/api/balcony-api/search/all"
    
    /// 충전내역
    case coinChargeHistory = "/api/balcony-api/payment/charge"
    
    /// 구매내역
    case purchaseHistory = "/api/balcony-api/purchase"
    
    /// iP 주소
    case ipAddress  = "https://api.ipify.org/?format=json"
    
    /// 유저 코인 조회
    case userCoinBalance = "/api/balcony-api/coin/user"
    
    
    case mainBanner = "/api/balcony-api/banner/list/MAIN"
    
    var baseURL: String {
        return AppContext.shared.baseApiUrl
    }
    
    var url: String {
        if self == .ipAddress {
            return self.rawValue
        } else {
            return baseURL + self.rawValue
        }
    }
}
