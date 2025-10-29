//
//  ContentsBannerItemEntity.swift
//  LezhinSnack
//
//  Created by lwc on 9/11/25.
//

import Foundation

struct ContentsBannerItemEntity: Hashable {
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

    let genreTag: TagInfoEntity?
    let keywordTags: [TagInfoEntity]?

    let badges: [BadgeEntity]

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

extension ContentsBannerItemEntity {
    init(dto: ContentsBannerItemDTO) {
        self.bannerId = dto.bannerId
        self.bannerType = dto.bannerType
        self.bannerTitle = dto.bannerTitle
        self.bannerImagePath = dto.bannerImagePath

        self.contentsId = dto.contentsId
        self.contentsAlias = dto.contentsAlias
        self.contractType = dto.contractType
        self.synopsis = dto.synopsis

        self.signatureImagePath = dto.signatureImagePath
        self.titleImagePath = dto.titleImagePath

        self.signatureText = dto.signatureText
        self.signatureBackgroundColor = dto.signatureBackgroundColor

        self.genreTag = dto.genreTag.map(TagInfoEntity.init(dto:))
        self.keywordTags = dto.keywordTags?.map(TagInfoEntity.init(dto:))

        self.badges = dto.badges.map(BadgeEntity.init(dto:))

        self.bannerTarget = dto.bannerTarget
        self.targetLink = dto.targetLink
        self.targetContentsAlias = dto.targetContentsAlias
        self.targetEpisodeAlias = dto.targetEpisodeAlias
        self.targetNoticeId = dto.targetNoticeId

        self.bannerTargetUser = dto.bannerTargetUser
        self.platforms = dto.platforms

        self.isShow = dto.isShow
        self.startedAt = dto.startedAt
        self.endedAt = dto.endedAt
    }
}


extension ContentsBannerItemEntity {
    /// 키워드 태그의 name만 뽑아 배열로 반환
    var keywordNames: [String] {
        (keywordTags ?? []).map { $0.name }
    }

    /// 최대 개수 제한이 필요하면 이거 사용
    func keywordNames(limit: Int) -> [String] {
        let names = (keywordTags ?? []).map { $0.name }
        return Array(names.prefix(limit))
    }
}
