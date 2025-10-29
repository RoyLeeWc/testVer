//
//  UserCoinDTO.swift
//  LezhinSnack
//
//  Created by 신진우 on 6/3/25.
//


struct UserCoinDTO: Codable {
    var coin: Int
    var bonusCoin: Int
    var expiringCoin: Int
    var expiringWindowDays: Int
}
