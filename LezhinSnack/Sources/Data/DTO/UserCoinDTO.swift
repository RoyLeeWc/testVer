//
//  UserCoinDTO.swift
//  LezhinSnack
//
//  Created by 신진우 on 6/3/25.
//


struct UserCoinDTO: Decodable {
    let responseCode: String
    let data: UserCoinDataDTO?
    let errorData: ErrorDataDTO?
}

struct UserCoinDataDTO: Decodable {
    let coin: Int64
    let bonusCoin: Int64
    let expiringCoin: Int64
    let expiringWindowDays: Int64
}

extension UserCoinDataDTO {
    func toEntity() -> UserCoinEntity {
        UserCoinEntity(
            coin: coin,
            bonusCoin: bonusCoin,
            expiringCoin: expiringCoin,
            expiringWindowDays: expiringWindowDays
        )
    }
}
