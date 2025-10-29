//
//  ContentsOngoingItemEntity.swift
//  LezhinSnack
//
//  Created by lwc on 9/11/25.
//

import Foundation

struct ContentsOngoingItemEntity: Hashable {
    let contentsId: String
    let contentsAlias: String
    let episodeId: String
    let contentsOpenedAt: Int64?
    let coverImagePath: String?
    let episodeAlias: String
    let episodeOpenedAt: Int64
    let marks: [MarkEntity]
}

extension ContentsOngoingItemEntity {
    init(dto: ContentsOngoingItemDTO) {
        self.contentsId = dto.contentsId
        self.contentsAlias = dto.contentsAlias
        self.episodeId = dto.episodeId
        self.contentsOpenedAt = dto.contentsOpenedAt
        self.coverImagePath = dto.coverImagePath
        self.episodeAlias = dto.episodeAlias
        self.episodeOpenedAt = dto.episodeOpenedAt
        self.marks = dto.marks.map(MarkEntity.init(dto:))
    }
}
