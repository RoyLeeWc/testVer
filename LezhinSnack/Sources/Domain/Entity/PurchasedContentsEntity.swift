//
//  PurchasedContentsEntity.swift
//  LezhinSnack
//
//  Created by lwc on 9/18/25.
//

import Foundation

struct PurchasedContentItemEntity: Hashable {
    let contentsId: String
    let lastViewedEpisodeId: String?
    let title: String
    let purchasedEpisodeCount: Int
    let lastPurchasedAt: Date
    let thumbnailUrl: String
    let contentsAlias: String
    let isNewEpisode: Bool
}

struct PurchasedContentsPageEntity: Hashable {
    let items: [PurchasedContentItemEntity]
    let pageNumber: Int
    let pageSize: Int
    let totalElements: Int
    let totalPages: Int
    let isFirst: Bool
    let isLast: Bool
    let numberOfElements: Int
    let isEmpty: Bool
}
