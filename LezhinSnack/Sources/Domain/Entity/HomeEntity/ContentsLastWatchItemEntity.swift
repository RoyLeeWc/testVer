//
//  ContentsLastWatchItemEntity.swift
//  LezhinSnack
//
//  Created by lwc on 9/11/25.
//

import Foundation

struct ContentsLastWatchItemEntity: Hashable {
    let contentsId: String?
    let contentsAlias: String
    let thumbnailUrl: String?
    let currentEpisode: Int?
    let maxEpisode: Int?
}

extension ContentsLastWatchItemEntity {
    init(dto: ContentsLastWatcItemDTO) {
        self.contentsId = dto.contentsId
        self.contentsAlias = dto.contentsAlias
        self.thumbnailUrl = dto.thumbnailUrl
        self.currentEpisode = dto.currentEpisode
        self.maxEpisode = dto.maxEpisode
    }
}
