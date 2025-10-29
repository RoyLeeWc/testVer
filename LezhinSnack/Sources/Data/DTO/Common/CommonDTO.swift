//
//  CommonDTO.swift
//  LezhinSnack
//
//  Created by lwc on 10/1/25.
//

// MARK: - Common
struct PageableDTO: Decodable {
    let pageNumber: Int
    let pageSize: Int
    let sort: SortDTO
    let offset: Int
    let unpaged: Bool
    let paged: Bool
}

struct SortDTO: Decodable {
    let empty: Bool
    let unsorted: Bool
    let sorted: Bool
}


struct PurchaseUserContext {
    let paymentMenuType: String
    let paymentProviderId: String
    let productId: Int
}

struct ReserveResultEntity {
    let tradeId: String
    let productCode: String
}
