//
//  CoinChargesDTO.swift
//  LezhinSnack
//
//  Created by lwc on 10/1/25.
//

import Foundation


struct MyCoinChargesDTO: Decodable {
    let responseCode: String
    let data: MyCoinChargesDataDTO?
    let errorData: ErrorDataDTO?
}


struct MyCoinChargesDataDTO: Decodable {
    let content: [CoinChargeItemDTO]
    let pageable: PageableDTO
    let first: Bool
    let last: Bool
    let size: Int
    let number: Int
    let sort: SortDTO
    let numberOfElements: Int
    let empty: Bool
}

struct CoinChargeItemDTO: Decodable {
    let title: String
    let coinType: String          // "COIN" | "BONUS"
    let coinTitleType: String     // "ADMIN" | "BONUS_COIN" | "COIN" | "ADMIN_CUSTOM"
    let initialAmount: Int
    let remainAmount: Int
    let expiredAt: Int64          // ms
    let createdAt: Int64          // ms
}

extension MyCoinChargesDataDTO {
    func toEntity() -> PagedEntity<CoinChargeEntity> {
        let items = content.map {
            CoinChargeEntity(
                title: $0.title,
                coinType: CoinType(rawValue: $0.coinType) ?? .unknown,
                coinTitleType: CoinTitleType(rawValue: $0.coinTitleType) ?? .unknown,
                initialAmount: $0.initialAmount,
                remainAmount: $0.remainAmount,
                expiredAt: $0.expiredAt,
                createdAt: $0.createdAt
            )
        }
        return PagedEntity(
            items: items,
            page: number,
            size: size,
            isFirst: first,
            isLast: last,
            totalOnPage: numberOfElements
        )
    }
}
