//
//  DisplayEpisodeEntity.swift
//  LezhinSnack
//
//  Created by lwc on 9/18/25.
//

import Foundation

struct DisplayEpisodeEntity: Hashable {
    let episodeId: String
    let episodeAlias: String
    let episodeOpenedAt: Date?
    let episodePreviewOpenedAt: Date?
    let possessionCoin: Int
    let prevEpisodeAlias: String?
    let nextEpisodeAlias: String?
}
