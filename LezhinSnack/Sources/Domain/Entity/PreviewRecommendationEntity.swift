//
//  PreviewRecommendationEntity.swift
//  LezhinSnack
//
//  Created by lwc on 9/18/25.
//
import Foundation

struct PreviewRecommendationEntity: Hashable {
    let previewRecommendationId: String                           // previewRecommendationId
    let items: [PreviewRecommendationItem]
}

struct PreviewRecommendationItem: Hashable {
    let contentsId: String
    let contentsAlias: String
    let episodeId: String
    let titleImageUrl: String
}
