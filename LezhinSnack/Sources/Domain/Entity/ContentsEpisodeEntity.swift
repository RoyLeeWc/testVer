//
//  ContentsEpisodeEntity.swift
//  LezhinSnack
//
//  Created by lwc on 9/18/25.
//

import Foundation

enum EpisodeType: Hashable {
    case promotion
    case general
    case teaser
    case unknown(String)

    init(raw: String) {
        switch raw.uppercased() {
        case "PROMOTION": self = .promotion
        case "GENERAL":   self = .general
        case "TEASER":    self = .teaser
        default:          self = .unknown(raw)
        }
    }
}

struct ContentsEpisodeEntity: Hashable {
    let episodeId: String
    let type: EpisodeType
    let alias: String
    let isFree: Bool
    let isPreview: Bool
    let openedAt: Int64?       // seconds/ms 입력 모두 허용 → Date 변환
    let previewOpenedAt: Int64?
}
