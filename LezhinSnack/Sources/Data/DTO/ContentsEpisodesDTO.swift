//
//  ContentsEpisodesDTO.swift
//  LezhinSnack
//
//  Created by lwc on 9/18/25.
//

import Foundation

struct ContentsEpisodesDTO: Decodable {
    let responseCode: String?
    let data: ContentsEpisodesDataDTO?
    let errorData: ErrorDataDTO?
}

struct ContentsEpisodesDataDTO: Decodable {
    /// 에피소드 목록 (required in schema)
    let episodes: [EpisodeSummaryDTO]?
}

struct EpisodeSummaryDTO: Decodable {
    let episodeId: String?
    /// required: "PROMOTION" | "GENERAL" | "TEASER"
    let type: String?
    let alias: String?
    let isFree: Bool?
    let isPreview: Bool?
    /// required: Unix Timestamp (seconds) — 서버가 ms를 보낼 가능성 고려해 Int64 사용
    let openedAt: Int64?
    /// nullable: Unix Timestamp (seconds)
    let previewOpenedAt: Int64?
}
