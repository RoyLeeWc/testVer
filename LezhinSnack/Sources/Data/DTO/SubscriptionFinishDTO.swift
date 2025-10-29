//
//  SubscriptionFinishDTO.swift
//  LezhinSnack
//
//  Created by 신진우 on 6/3/25.
//


struct SubscriptionFinishDTO: Decodable {
    let result: String           // "SUCCESS" / "FAILURE"
    let data: SubscriptionFinishData?
}

struct SubscriptionFinishData: Decodable {
    let isActive: Bool            // 구독이 실제로 활성화되었는지
    let nextBillingDate: Int?     // UNIX timestamp
    let expirationDate: Int?      // UNIX timestamp (구독이 언제 만료되는지)
}