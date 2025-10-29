//
//  DisplayContentsEntity.swift
//  LezhinSnack
//
//  Created by lwc on 9/18/25.
//

import Foundation

struct DisplayContentsDetailEntity: Hashable {
    struct Creator: Hashable {
        let realName: String
        let creatorId: String
        let creatorRoleType: String
    }
    struct Tag: Hashable {
        let name: String
        let tagId: String
        let orderNumber: Int
    }
    
    let id: String
    let alias: String
    let contact: String?
    
    let ageRatingType: String?
    let ageRatingReasons: [String]
    let contractType: String?
    
    let signatureBackgroundColor: String?
    let signatureImagePath: String?
    let title: String
    let synopsis: String?
    let signatureText: String?
    let coverImagePath: String?
    let titleImagePath: String?
    
    let creators: [Creator]
    let genreTags: [Tag]
    let keywordTags: [Tag]
    
    let contentsOpenedAt: Date?
    let contentsClosedAt: Date?
    let exposurePlatform: [String]
    let contentsIsShow: Bool
    let episodeCount: Int
    let isComplete: Bool
    var isLiked: Bool
    var likesCount: Int
    var isFavorite: Bool
    let purchasedEpisodes: [PurchasedEpisodeEntity]?
    let firstEpisodeAlias: String?
}

