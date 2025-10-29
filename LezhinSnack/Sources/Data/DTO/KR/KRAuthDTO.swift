//
//  LoginModel.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/8/25.
//

import Foundation


struct KRAuthDTO: Codable {
    let result: String
    let data: LoginSuccessData?
    let error: KRAPIError?
}

// MARK: - 성공 리스폰스 모델
struct AccessToken: Codable {
    let token: String
    let createdAt: Int64
    let expiredAt: Int64
}

struct RefreshToken: Codable {
    let token: String
    let createdAt: Int64
    let expiredAt: Int64
}

struct LoginSuccessData: Codable {
    let accessToken: AccessToken
    let refreshToken: RefreshToken
    let email: String?
    let userId: Int?
    let isSignUp: Bool?
}
