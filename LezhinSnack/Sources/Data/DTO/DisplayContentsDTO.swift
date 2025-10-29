//
//  DisplayContentsDTO.swift
//  LezhinSnack
//
//  Created by lwc on 9/18/25.
//

import Foundation

struct DisplayContentsDTO: Decodable {
    let responseCode: String?
    let data: DisplayContentsDataDTO?
    let errorData: ErrorDataDTO?
}

struct DisplayContentsDataDTO: Decodable {
    let id: String?
    let alias: String?
    let contact: String?
    
    let ageRatingType: String?
    let ageRatingReasons: [String]?
    let contractType: String?
    
    let signatureBackgroundColor: String?
    let signatureImagePath: String?
    let title: String?
    let synopsis: String?
    let signatureText: String?
    let coverImagePath: String?
    let titleImagePath: String?
    
    let creators: [CreatorDTO]?
    let genreTags:[TagDTO]?
    let keywordTags: [TagDTO]?
    
    let contentsOpenedAt: Int64?   // epoch ms
    let contentsClosedAt: Int64?   // epoch ms
    let exposurePlatform: [String]?
    let contentsIsShow: Bool?
    let episodeCount: Int?
    let isComplete: Bool?
    let isLiked: Bool?
    let likesCount: Int?
    let isFavorite: Bool?
    let purchasedEpisodes: [PurchasedEpisodeInDetailDTO]
    let firstEpisodeAlias: String?
}

struct PurchasedEpisodeInDetailDTO: Decodable {
    let episodeId: String
    let purchaseType: String?
}

struct CreatorDTO: Decodable {
    let realName: String?
    let creatorId: String?
    let creatorRoleType: String?
}

struct TagDTO: Decodable {
    let name: String?
    let tagId: String?
    let orderNumber: Int?
}
