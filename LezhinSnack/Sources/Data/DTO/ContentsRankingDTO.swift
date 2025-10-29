//
//  ContentsRankingDTO.swift
//  LezhinSnack
//
//  Created by lwc on 9/10/25.
//

struct ContentsRankingDTO: Decodable {
    let responseCode: String
    let data: [ContentsRankingItemDTO]
    let errorData: ErrorDataDTO? 
}

struct ContentsRankingItemDTO: Decodable {
    let rank: Int
    let contentsId: String
    let contentsAlias: String
    let contentsDetail: ContentsDetailInfoDTO?
    let badges: [BadgeTypeDTO]
}

struct ContentsDetailInfoDTO: Decodable {
    let coverImagePath: String
    let title: String
    let genreTag: TagInfoDTO?
    let keywordTags: [TagInfoDTO]
}

