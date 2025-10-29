//
//  MyListDTO.swift
//  LezhinSnack
//
//  Created by lwc on 10/13/25.
//

import Foundation

struct PurchasedContentsDTO: Decodable {
    let responseCode: String?
    let data: PurchasedPageDTO?
    let errorData: ErrorDataDTO?
}

struct PurchasedPageDTO: Decodable {
    let content: [PurchasedItemDTO]?
    let pageable: PageableDTO?
    // 페이징
    let last: Bool?
    let totalElements: Int?
    let totalPages: Int?
    let first: Bool?
    let size: Int?
    let number: Int?
    let numberOfElements: Int?
    let empty: Bool?
    // 서버가 data 루트에도 sort를 내려줄 수 있어 누락되면 무시됨
    let sort: SortDTO?
}

struct PurchasedItemDTO: Decodable {
    let contentsId: String
    let lastViewedEpisodeId: String?
    let title: String
    let purchasedEpisodeCount: Int
    let isNewEpisode: Bool
    let lastPurchasedAt: Int64     // epoch ms
    let thumbnailUrl: String
    let contentsAlias: String
}


struct WishContentsDTO: Decodable {
    let responseCode: String?
    let data: WishPageDTO?
    let errorData: ErrorDataDTO?
}

struct WishPageDTO: Decodable {
    let content: [WishItemDTO]?
    let pageable: PageableDTO?
    // 페이징
    let last: Bool?
    let totalElements: Int?
    let totalPages: Int?
    let first: Bool?
    let size: Int?
    let number: Int?
    let numberOfElements: Int?
    let empty: Bool?
    let sort: SortDTO?
}

struct WishItemDTO: Decodable {
    let contentsId: String
    let lastFavoriteEpisodeId: String
    let title: String
    let isNewEpisode: Bool
    let lastFavoriteAt: Int64    // epoch ms
    let thumbnailUrl: String
    let contentsAlias: String
}



struct LastViewedContentsDTO: Decodable {
    let responseCode: String?
    let data: LastViewedPageDTO?
    let errorData: ErrorDataDTO?
}

struct LastViewedPageDTO: Decodable {
    let content: [LastViewedItemDTO]?
    let pageable: PageableDTO?
    // 페이징
    let last: Bool?
    let totalElements: Int?
    let totalPages: Int?
    let first: Bool?
    let size: Int?
    let number: Int?
    let numberOfElements: Int?
    let empty: Bool?
    let sort: SortDTO?
}

struct LastViewedItemDTO: Decodable {
    let contentsId: String
    let lastViewedEpisodeId: String
    let title: String
    let lastViewedEpisodeNumber: Int
    let lastEpisodeNumber: Int
    let isNewEpisode: Bool
    let lastViewedAt: Int64         // epoch ms
    let thumbnailUrl: String
    let contentsAlias: String
}
