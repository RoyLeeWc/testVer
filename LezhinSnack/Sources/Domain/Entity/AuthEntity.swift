//
//  LoginModel.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/8/25.
//

import Foundation


struct AuthEntity: Codable {
    let userId: String
    let email: String
    let accessToken: String
    let refreshToken: String
    let accessExpiry: Double
    let refreshExpiry: Double
}
