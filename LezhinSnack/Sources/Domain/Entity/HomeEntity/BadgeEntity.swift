//
//  BadgeEntity.swift
//  LezhinSnack
//
//  Created by lwc on 9/11/25.
//

import Foundation

struct BadgeEntity: Hashable {
    let type: BadgeType
}

enum BadgeType: String, Hashable, CaseIterable {
    case lezhinOriginal   = "LEZHIN_ORIGINAL"
    case bomtoonOriginal  = "BOMTOON_ORIGINAL"
    case generalOriginal  = "GENERAL_ORIGINAL"
    case top10Entry       = "TOP_10_ENTRY"
    case risingPopularity = "RISING_POPULARITY"
    case newRelease       = "NEW_RELEASE"
    case likeBest         = "LIKE_BEST"
    case favoriteBest     = "FAVORITE_BEST"
    case unknown          = "UNKNOWN"

    init(dto: BadgeTypeDTO) {
        self = BadgeType(rawValue: dto.rawValue) ?? .unknown
    }
}

extension BadgeEntity {
    
    init(dto: BadgeTypeDTO) {
        self.init(type: BadgeType(dto: dto))
    }
}
