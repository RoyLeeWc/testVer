//
//  CurationBannerDTO.swift
//  LezhinSnack
//
//  Created by lwc on 9/11/25.
//

struct ContentsBannerDTO: Decodable {
    let responseCode: String
    let data: [ContentsBannerItemDTO]
    let errorData: ErrorDataDTO?
}

struct ContentsBannerItemDTO: Decodable {
    let bannerId: String
    let bannerType: String
    let bannerTitle: String
    let bannerImagePath: String
    
    let contentsId: String?
    let contentsAlias: String?
    let contractType: String?
    let synopsis: String?
    
    
    let signatureImagePath: String?
    let titleImagePath: String?
    
    let signatureText: String?
    let signatureBackgroundColor: String?
    
    let genreTag: TagInfoDTO?
    let keywordTags: [TagInfoDTO]?
    
    let badges: [BadgeTypeDTO]
    
    let bannerTarget: String
    let targetLink: String?
    let targetContentsAlias: String?
    let targetEpisodeAlias: String?
    let targetNoticeId: Int?
    
    let bannerTargetUser: String
    let platforms: [String]
    
    let isShow: Bool
    let startedAt: Int64
    let endedAt: Int64
}
