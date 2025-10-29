//
//  KRBannerDTO.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/13/25.
//



import Foundation

// API 응답 DTO
struct KRBannerDTO: Decodable {
    let result: String?
    let data: [BannerDTO]?
    let error: KRAPIError?  // 서버 에러 응답 모델
}

// 개별 배너 객체
struct BannerDTO: Decodable {
    let bannerType: String?
    let id: Int64?
    let title: String?
    let serviceTitle: String?
    let orderNo: Int?
    let weight: Int?
    let openedAt: Int64?
    let closedAt: Int64?
    let detailInfo: DetailInfo?
    let linkInfo: LinkInfo?
    let thumbnails: [BannerThumbnail]?
    let ageInfo: AgeInfo?
    let menuInfo: MenuInfo?
    let badgeInfo: [BadgeInfo]?
    let createdAt: Int64?
    let tagPreferences: String?
}

// detailInfo 내부
struct DetailInfo: Decodable {
    let additionalProp1: String?
    let additionalProp2: String?
    let additionalProp3: String?
}

// linkInfo 내부
struct LinkInfo: Decodable {
    let additionalProp1: String?
    let additionalProp2: String?
    let additionalProp3: String?
}

// thumbnails 배열 항목
struct BannerThumbnail: Decodable {
    let imagePath: String?
    let type: String?
    let isAdult: Bool?
    let width: Int?
    let height: Int?
}

// ageInfo 내부
struct AgeInfo: Decodable {
    let isNonAdult: Bool?
    let isAdult: Bool?
}

// menuInfo 내부
struct MenuInfo: Decodable {
    let isWeekly: Bool?
    let isFree: Bool?
}

// badgeInfo 배열 항목
struct BadgeInfo: Decodable {
    let contentsId: Int64?
    let isAdult: Bool?
    let thumbnails: [BadgeThumbnail]?
    let badgeFreetime: Bool?
    let badgeFree: Int?
    let badgeDiscount: Int?
    let freeEpCount: Int?
    let discountEpCount: Int?
}

// badgeInfo 내부의 thumbnails
struct BadgeThumbnail: Decodable {
    let imagePath: String?
    let type: String?
}
