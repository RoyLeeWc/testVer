//
//  KRUserCoinDTO.swift
//  LezhinSnack
//
//  Created by 신진우 on 6/3/25.
//


import Foundation

public struct KRUserCoinDTO: Decodable {
    let result: String
    let data: UserCoinDataDTO?
    let error: KRAPIError?
}

struct UserCoinDataDTO: Codable {
    let coin: Int64?
    let freeCoin: Int64?
    let bonusCoin: Int64?
    let mileage: Int64?
    let coinExpiredAt: Int64?
    let bonusCoinExpiredAt: Int64?
    let mileageExpiredAt: Int64?
}
