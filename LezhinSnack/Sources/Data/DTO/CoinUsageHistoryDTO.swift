//
//  CoinHistoryDTO.swift
//  LezhinSnack
//
//  Created by lwc on 10/1/25.
//

import Foundation


struct CoinUsageHistoryDTO: Decodable {
    let responseCode: String
    let data: CoinUsageHistoryDataDTO?
    let errorData: ErrorDataDTO?
}


struct CoinUsageHistoryDataDTO: Decodable {
    let content: [CoinUsageItemDTO]
    let pageable: PageableDTO
    let first: Bool
    let last: Bool
    let size: Int
    let number: Int
    let sort: SortDTO
    let numberOfElements: Int
    let empty: Bool
}


struct CoinUsageItemDTO: Decodable {
    let title: String
    let coinStatusType: String    // "USE" 등
    let coin: Int
    let createdAt: Int64          // ms
}

extension CoinUsageHistoryDataDTO {
    func toEntity() -> PagedEntity<CoinUsageEntity> {
        let items = content.map {
            CoinUsageEntity(
                title: $0.title,
                coinStatusType: CoinStatusType(rawValue: $0.coinStatusType) ?? .unknown,
                coin: $0.coin,
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
