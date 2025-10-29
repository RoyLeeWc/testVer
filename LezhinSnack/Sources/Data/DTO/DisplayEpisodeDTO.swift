//
//  DisplayEpisodeDTO.swift
//  LezhinSnack
//
//  Created by lwc on 9/18/25.
//

import Foundation

struct DisplayEpisodeDTO: Decodable {
    let responseCode: String?
    let data: DisplayEpisodeDataDTO?
    let errorData: ErrorDataDTO?
}

struct DisplayEpisodeDataDTO: Decodable {
    let episodeId: String?
    let episodeAlias: String?
    let episodeOpenedAt: Int64?           // epoch ms
    let episodePreviewOpenedAt: Int64?    // epoch ms
    let possessionCoin: Int?
    let prevEpisodeAlias: String?
    let nextEpisodeAlias: String?
}
