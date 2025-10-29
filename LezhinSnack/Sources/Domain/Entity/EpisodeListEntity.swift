//
//  ContentsListEntity.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/9/25.
//



struct EpisodeListEntity: Codable,Hashable {
    let contentsID: Int
    let episodeID: Int
    let episodeIndex: Int
    let isLocked: Bool
    let isEarlyAccess: Bool
    
    var isFirstEarlyAccess: Bool = false
}
