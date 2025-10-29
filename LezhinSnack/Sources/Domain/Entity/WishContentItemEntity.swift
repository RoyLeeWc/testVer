//
//  WishContentItemEntity.swift
//  LezhinSnack
//
//  Created by lwc on 10/13/25.
//

import Foundation

struct WishContentItemEntity: Hashable {
    let contentsId: String
    let lastFavoriteEpisodeId: String
    let title: String
    let isNewEpisode: Bool
    let lastFavoriteAt: Date
    let thumbnailUrl: String
    let contentsAlias: String
}

struct WishContentsPageEntity: Hashable {
    let items: [WishContentItemEntity]
    let pageNumber: Int
    let pageSize: Int
    let totalElements: Int
    let totalPages: Int
    let isFirst: Bool
    let isLast: Bool
    let numberOfElements: Int
    let isEmpty: Bool
}
