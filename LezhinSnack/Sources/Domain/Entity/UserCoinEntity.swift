//
//  UserCoinEntity.swift
//  LezhinSnack
//
//  Created by 신진우 on 6/3/25.
//



struct UserCoinEntity: Codable {
    var coin: Int64
    var bonusCoin: Int64
    var expiringCoin: Int64
    var expiringWindowDays: Int64
}

