//
//  HomeSectionRepository.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/12/25.
//

import Foundation


protocol HomeSectionRepositoryProtocol {
//    func fetchSectionList() async throws -> [HomeSection]
//    func fetchMainBannerData() async throws -> [HomeSectionEntity]
//    func fetchRankingData() async throws -> [HomeSectionEntity]
//    func fetchWatchHistoryData() async throws -> [HomeSectionEntity]
//    func fetchOriginalData() async throws -> [HomeSectionEntity]
//    func fetchCurationData() async throws -> [HomeSectionEntity]
//    func fetchAllContentsData() async throws -> [HomeSectionEntity]
//    func fetchSerializeData() async throws -> [HomeSectionEntity]
}


final class HomeSectionRepository: HomeSectionRepositoryProtocol {
    
//    func fetchSectionList() async throws -> [HomeSection] {
//        return [
//            HomeSection(type: .mainBanner, headerTitle: nil),
//            HomeSection(type: .ranking, headerTitle: "Ranking"),
//            HomeSection(type: .watchHistory, headerTitle: "Watch History"),
//            HomeSection(type: .curation, headerTitle: "기다리던 NEW 에피소드 도착"),
//            HomeSection(type: .original, headerTitle: "Original"),
//            HomeSection(type: .curation, headerTitle: "화끈한 불륜맛"),
//            HomeSection(type: .curation, headerTitle: "시원한 사이다맛"),
//            HomeSection(type: .curation, headerTitle: "근데 왜 불륜이 화끈함?"),
//            HomeSection(type: .curation, headerTitle: "암튼 그렇데"),
//            HomeSection(type: .allContents, headerTitle: "모든 작품 모아보기")
//        ]
//    }
//    
//    func fetchMainBannerData() async throws -> [HomeSectionEntity] {
//        
//        let parameters: [String: Any] = ["displayRange": BannerType.comic]
//        let mainBannerRequest = BannerAPIRequest(parameters: parameters)
//        let mainBannerResponse: KRBannerDTO = try await NetworkService.shared.requestAsync(mainBannerRequest)
//        
//        guard mainBannerResponse.result == LZSConstant.ResponseSuccess,
//              let data = mainBannerResponse.data else {
//            throw NSError(
//                domain: "BannerError",
//                code: -1,
//                userInfo: nil
//            )
//        }
//        
//        var originalBannerItems: [HomeSectionEntity] =  data.compactMap { bannerItem in
//            var thumbnailImagePath: String?
//            for thumbnail in bannerItem.thumbnails ?? [] {
//                if thumbnail.type == "MOBILE" {
//                    thumbnailImagePath = thumbnail.imagePath
//                }
//            }
//            
//            return HomeSectionEntity(title: "Banner",
//                                     color: LZSUtil.getRandomUIColor(),
//                                     thumbnailImagePath: thumbnailImagePath)
//            
//        }
//        
//        var repeatedBannerItems: [HomeSectionEntity] = []
//        for _ in 0..<20 {
//            for item in originalBannerItems {
//                repeatedBannerItems.append(HomeSectionEntity(title: item.title, color: item.color))
//            }
//        }
//        return repeatedBannerItems
//    }
//    
//    func fetchRankingData() async throws -> [HomeSectionEntity] {
//        return (0..<12).map { HomeSectionEntity(title: "Ranking \($0 + 1)") }
//    }
//    
//    func fetchWatchHistoryData() async throws -> [HomeSectionEntity] {
//        return (0..<10).map { HomeSectionEntity(title: "Watch \($0)") }
//    }
//    
//    func fetchOriginalData() async throws -> [HomeSectionEntity] {
//        var originalItems: [HomeSectionEntity] = []
//        for index in 0..<5 {
//            originalItems.append(HomeSectionEntity(title: "Original \(index + 1)", color: LZSUtil.getRandomUIColor()))
//        }
//        var repeatedBannerItems: [HomeSectionEntity] = []
//        for _ in 0..<20 {
//            for item in originalItems {
//                repeatedBannerItems.append(HomeSectionEntity(title: item.title, color: item.color))
//            }
//        }
//        return repeatedBannerItems
//    }
//    
//    func fetchCurationData() async throws -> [HomeSectionEntity] {
//        return (0..<10).map { HomeSectionEntity(title: "Item \($0)") }
//    }
//    
//    func fetchAllContentsData() async throws -> [HomeSectionEntity] {
//        return (0..<31).map { HomeSectionEntity(title: "Vertical Item \($0)") }
//    }
//    
//    func fetchSerializeData() async throws -> [HomeSectionEntity] {
//        return (0..<31).map { HomeSectionEntity(title: "Vertical Item \($0)") }
//    }
}
