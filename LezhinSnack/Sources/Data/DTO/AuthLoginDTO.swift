//
//  AuthLoginDTO.swift
//  LezhinSnack
//
//  Created by lwc on 9/8/25.
//

import Foundation

struct AuthLoginDTO: Decodable {
    let responseCode: String
    let data: AuthLoginDataDTO?
    let errorData: ErrorDataDTO?
}

struct AuthLoginDataDTO: Decodable {
    let userId: Int
    let joinType: String?
    let accessToken: TokenDTO
    let refreshToken: TokenDTO
    let isGuest: Bool?
}

struct TokenDTO: Decodable {
    let token: String
    let createdAt: Int64
    let expiredAt: Int64
}
