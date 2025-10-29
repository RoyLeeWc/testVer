//
//  ContentsRankingItemEntity.swift
//  LezhinSnack
//
//  Created by lwc on 9/11/25.
//

import Foundation

struct ContentsRankingItemEntity: Hashable {
    let rank: Int
    let contentsId: String
    let contentsAlias: String
    let contentsDetail: ContentsDetailInfoEntity?
    let badges: [BadgeEntity]
}

extension ContentsRankingItemEntity {
    init(dto: ContentsRankingItemDTO) {
        self.rank = dto.rank
        self.contentsId = dto.contentsId
        self.contentsAlias = dto.contentsAlias
        self.contentsDetail = dto.contentsDetail.map(ContentsDetailInfoEntity.init(dto:))
        self.badges = dto.badges.map(BadgeEntity.init(dto:))
    }
}
