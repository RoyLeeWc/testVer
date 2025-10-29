//
//  PaymentHistoriesDTO.swift
//  LezhinSnack
//
//  Created by lwc on 10/10/25.
//

// MARK: - Payment List DTO
struct PaymentHistoriesDTO: Decodable {
    let responseCode: String
    let data: PaymentHistoryPageDTO?
    let errorData: ErrorDataDTO?
}

struct PaymentHistoryPageDTO: Decodable {
    let content: [PaymentHistoryItemDTO]
    let pageable: PageableDTO
    let totalPages: Int?
    let totalElements: Int?
    let last: Bool
    let size: Int
    let number: Int
    let sort: SortDTO
    let numberOfElements: Int
    let first: Bool
    let empty: Bool
}

struct PaymentHistoryItemDTO: Decodable {
    let tradeId: String
    let paymentMenuType: String               // "COIN_PRODUCT" | "SUBSCRIPTION_PRODUCT"
    let amount: Int                           // 스펙은 number지만 샘플 int → Int로 수용
    let currencyType: String                  // "KRW" | "USD" | "JPY" | "CNY"
    let periodType: String                    // "ONE_TIME_PURCHASE" | "MONTHLY" | "ANNUAL"
    let createdAt: Int64                     // null 가능
}



// MARK: - Payment Detail DTO
struct PaymentDetailDTO: Decodable {
    let responseCode: String
    let data: PaymentDetailDataDTO?
    let errorData: ErrorDataDTO?
}

struct PaymentDetailDataDTO: Decodable {
    let tradeId: String
    let paymentMenuType: String               // "COIN_PRODUCT" | "SUBSCRIPTION_PRODUCT"
    let status: String                        // "COMPLETE" | "FAIL" | "CANCEL" | "CANCEL_PG"
    let amount: Int
    let currencyType: String                  // "KRW" | "USD" | "JPY" | "CNY"
    let coin: Int
    let periodType: String?                   // null 가능
    let paymentProviderType: String           // "IOS_APP" | "AND_PLAY"
    let createdAt: Int64
}
