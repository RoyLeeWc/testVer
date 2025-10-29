//
//  SubscriptionInquiryDTO.swift
//  LezhinSnack
//
//  Created by 신진우 on 6/3/25.
//


struct SubscriptionInquiryDTO: Decodable {
    let result: String           // "SUCCESS" / "FAILURE"
    let data: SubscriptionInquiryData?
}

struct SubscriptionInquiryData: Decodable {
    let status: String            // "ACTIVE" / "CANCELLED" / "EXPIRED"
    let expirationDate: Int?      // UNIX timestamp
    let transactionId: String?    // 가장 최근 StoreKit 트랜잭션 ID
}
