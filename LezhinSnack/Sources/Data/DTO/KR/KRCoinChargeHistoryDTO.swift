//
//  KRContentsHistory.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/12/25.
//


struct KRCoinChargeHistoryDTO: Codable {
    let result: String?
    let data: [CoinChargeItem]?
    let error: KRAPIError?
}


struct CoinChargeItem: Codable {
    let title: String?
    let coinStatus: String?
    let chargeMethod: String?
    let paymentMethod: String?
    let coin: Int?
    let freeCoin: Int?
    let bonusCoin: Int?
    let coinExpiredAt: Int64?
    let bonusCoinExpiredAt: Int64?
    let useDay: Int?
    let createdAt: Int64?
}
