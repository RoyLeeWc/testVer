//
//  WatchHistoryEntity.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/4/25.
//


struct WatchHistoryEntity: Codable, Hashable {
    var id: Int
    var title: String
    var thumbnailIUrl: String
    var watchedEpisode: Int
    var totalEpisodeCount: Int
    var watchedDate: String
    var viewingRate: Float
}
