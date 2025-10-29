//
//  ContentsListEntity.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/9/25.
//



struct EpisodeListEntity: Codable,Hashable {
    let contentsID: String
    let episodeID: String
    let episodeIndex: Int
    let isLocked: Bool
    let isEarlyAccess: Bool
    let contentsAlias: String
    let episodeAlias: String
     
    var isFirstEarlyAccess: Bool = false
}
