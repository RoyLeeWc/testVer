//
//  LastViewedContentItemEntity.swift
//  LezhinSnack
//
//  Created by lwc on 10/13/25.
//
import Foundation

struct LastViewedContentItemEntity: Hashable {
    let contentsId: String
    let lastViewedEpisodeId: String
    let title: String
    let lastViewedEpisodeNumber: Int
    let lastEpisodeNumber: Int
    let isNewEpisode: Bool
    let lastViewedAt: Date
    let thumbnailUrl: String
    let contentsAlias: String
}

struct LastViewedContentsPageEntity: Hashable {
    let items: [LastViewedContentItemEntity]
    let pageNumber: Int
    let pageSize: Int
    let totalElements: Int
    let totalPages: Int
    let isFirst: Bool
    let isLast: Bool
    let numberOfElements: Int
    let isEmpty: Bool
}
