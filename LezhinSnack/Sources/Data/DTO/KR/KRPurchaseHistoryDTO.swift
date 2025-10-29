//
//  KRPurchaseHistory.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/12/25.
//



struct KRPurchaseHistoryDTO: Codable {
    let result: String?
    let data: [PurchasedItem]?
    let error: KRAPIError?
}

// 응답 내의 개별 데이터 모델
struct PurchasedItem: Codable {
    let userId: Int?
    let title: String?
    let useCoin: Int?
    let purchaseType: String?
    let contentsId: Int?
    let contentsTitle: String?
    let episodeId: Int?
    let episodeTitle: String?
    let createdAt: Int64?
    let expiredAt: Int64?
}


