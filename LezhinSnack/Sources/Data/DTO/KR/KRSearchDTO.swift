//
//  KRSearchModel.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/9/25.
//

import Foundation


struct KRSearchDTO: Codable {
    let result: String?
    let data: SearchDataResponse?
    let error: KRAPIError?
}


// data 객체 모델
struct SearchDataResponse: Codable {
    let content: [SearchContent]?
    let pageable: Pageable?
    let id: Int?
    let order: Int?
    let search: String?
    let last: Bool?
    let totalPages: Int?
    let totalElements: Int?
    let size: Int?
    let number: Int?
    let sort: SortInfo?
    let numberOfElements: Int?
    let first: Bool?
    let empty: Bool?
}

// 작품(Content) 모델
struct SearchContent: Codable, Hashable {
    let id: Int?
    let alias: String?
    let title: String?
    let isAdult: Bool?
    let isComplete: Bool?
    let type: String?
    let thumbnails: [Thumbnail]?
    let badge: Badge?
    let viewCount: Int?
    let tag: String?
    //let devices: Devices?
    let updatedAt: Int?
    let openedAt: Int?
    let creators: String?
    let orderNo: Int?
}

// 썸네일 모델
struct Thumbnail: Codable,Hashable {
    let imagePath: String?
    let type: String?
    
    func hash(into hasher: inout Hasher) {
        // imagePath와 type만 골라서 해시 처리
        hasher.combine(imagePath)
        hasher.combine(type)
    }
    
    static func == (lhs: Thumbnail, rhs: Thumbnail) -> Bool {
        return lhs.imagePath == rhs.imagePath &&
               lhs.type == rhs.type
    }
}

// 배지(Badge) 모델
struct Badge: Codable, Hashable {
    let contentsId: Int?
    let newest: Bool?
    let adult: Bool?
    let scheduled: Bool?
    let short: Bool?
    let up: Bool?
    let completed: Bool?
    let discount: Int?
    let free: Int?
    let freetime: Bool?
    let original: Bool?
    let globalRelease: Bool?
    let viewCount: Int?
    
    func hash(into hasher: inout Hasher) {
        // imagePath와 type만 골라서 해시 처리
        hasher.combine(contentsId)
        hasher.combine(original)
    }
    
    static func == (lhs: Badge, rhs: Badge) -> Bool {
        return lhs.contentsId == rhs.contentsId &&
               lhs.original == rhs.original
    }
}

// 디바이스 정보 모델 (null일 수 있으므로 옵셔널)
struct Devices: Codable, Hashable {
    var uuid = UUID()
    let isWeb: Bool?
    let isAndPlay: Bool?
    let isIosApp: Bool?
}

// 페이지 관련 정보 모델
struct Pageable: Codable {
    let sort: SortInfo?
    let offset: Int?
    let pageNumber: Int?
    let pageSize: Int?
    let paged: Bool?
    let unpaged: Bool?
}

// 정렬 관련 정보 모델
struct SortInfo: Codable {
    let empty: Bool?
    let sorted: Bool?
    let unsorted: Bool?
}
