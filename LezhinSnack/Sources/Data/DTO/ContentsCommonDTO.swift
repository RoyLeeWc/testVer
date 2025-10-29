//
//  ContentsCommonDTO.swift
//  LezhinSnack
//
//  Created by lwc on 9/11/25.
//

struct TagInfoDTO: Decodable {
    let tagId: String
    let name: String
}

enum BadgeTypeDTO: String, Codable, CaseIterable {
    case lezhinOriginal   = "LEZHIN_ORIGINAL"
    case bomtoonOriginal  = "BOMTOON_ORIGINAL"
    case generalOriginal  = "GENERAL_ORIGINAL"
    case top10Entry       = "TOP_10_ENTRY"
    case risingPopularity = "RISING_POPULARITY"
    case newRelease       = "NEW_RELEASE"
    case likeBest         = "LIKE_BEST"
    case favoriteBest     = "FAVORITE_BEST"
    case unknown          = "UNKNOWN"

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        let raw = (try? c.decode(String.self)) ?? "UNKNOWN"
        self = BadgeTypeDTO(rawValue: raw) ?? .unknown
    }
}
