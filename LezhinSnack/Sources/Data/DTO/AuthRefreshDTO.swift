//
//  AuthRefreshDTO.swift
//  LezhinSnack
//
//  Created by lwc on 9/18/25.
//
import Foundation

struct AuthRefreshDTO: Decodable {
    let responseCode: String
    let data: AuthRefreshItemDTO?
    let errorData: ErrorDataDTO?
}

struct AuthRefreshItemDTO: Decodable {
    let userId: Int
    let accessToken: TokenDTO
    let refreshToken: TokenDTO
}
