//
//  PreviewRecommendationDTO.swift
//  LezhinSnack
//
//  Created by lwc on 9/18/25.
//
import Foundation

struct PreviewRecommendationDTO: Decodable {
    let responseCode: String
    let data: PreviewRecommendationResponseDTO
    let errorData: ErrorDataDTO?
}

struct PreviewRecommendationResponseDTO: Decodable {
    let previewRecommendationId: String
    let contents: [PreviewRecommendationItemDTO]
}

struct PreviewRecommendationItemDTO: Decodable {
    let contentsId: String
    let contentsAlias: String
    let episodeId: String
    let titleImageUrl: String
}
