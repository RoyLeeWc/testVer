//
//  MyListRepository.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/4/25.
//

import Foundation



protocol MyListRepositoryProtocol {
    func fetchWatchList() async throws -> [WatchHistoryEntity]
    func fetchWishList() async throws -> [WishListEntity]
    func fetchPurchasedList() async throws -> [PurchasedContentEntity]
    
    func deleteWatchList(itemId: Int)
    func deleteWishList(itemId: Int)
    func deletePurchasedList(itemId: Int)
    
    func sortWatchList(by: Int)
    func sortWishList(by: Int)
    func sortPurchasedList(by: Int)
}


final class MyListRepository: MyListRepositoryProtocol {
    
    func fetchWatchList() async throws -> [WatchHistoryEntity] {
        return generateRandomWatchHistory()
    }
    
    func fetchWishList() async throws -> [WishListEntity] {
        return generateRandomWishList()
    }
    
    func fetchPurchasedList() async throws -> [PurchasedContentEntity] {
        return generateRandomPurchasedList()
    }
    
    func deleteWatchList(itemId: Int) {
        
    }
    
    func deleteWishList(itemId: Int) {
        
    }
    
    func deletePurchasedList(itemId: Int) {
        
    }
    
    func sortWatchList(by: Int) {
        
    }
    
    func sortWishList(by: Int) {
        
    }
    
    func sortPurchasedList(by: Int) {
        
    }
    
    
    
    // MARK: - WatchHistory용 MOCK 데이터 생성 (id를 난수로 설정)
    private func generateRandomWatchHistory() -> [WatchHistoryEntity] {
        let count = Int.random(in: 10...100)
        var results: [WatchHistoryEntity] = []
        
        // 1) 중복 없는 난수 ID 세트 생성 (1...10000 범위)
        var uniqueIds = Set<Int>()
        while uniqueIds.count < count {
            uniqueIds.insert(Int.random(in: 1...1000000))
        }
        let idArray = Array(uniqueIds)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        let oneYearInSeconds: TimeInterval = 365 * 24 * 60 * 60
        
        for index in 0..<count {
            let id = idArray[index]
            let title = "사랑은 계약 후에 \(id)"
            let thumbnailIUrl = "mock_small_thumbnail"
            let totalEpisodeCount = Int.random(in: 1...50)
            let watchedEpisode = Int.random(in: 1...totalEpisodeCount)
            let randomOffset = TimeInterval.random(in: 0...oneYearInSeconds)
            let randomDate = Date().addingTimeInterval(-randomOffset)
            let watchedDate = dateFormatter.string(from: randomDate)
            let viewingRate = Float.random(in: 0...1)
            
            let entity = WatchHistoryEntity(
                id: id,
                title: title,
                thumbnailIUrl: thumbnailIUrl,
                watchedEpisode: watchedEpisode,
                totalEpisodeCount: totalEpisodeCount,
                watchedDate: watchedDate,
                viewingRate: viewingRate
            )
            results.append(entity)
        }
        
        return results
    }
    
    // MARK: - WishList용 MOCK 데이터 생성 (id를 난수로 설정)
    private func generateRandomWishList() -> [WishListEntity] {
        let count = Int.random(in: 10...100)
        var results: [WishListEntity] = []
        
        // 1) 중복 없는 난수 ID 세트 생성 (1...10000 범위)
        var uniqueIds = Set<Int>()
        while uniqueIds.count < count {
            uniqueIds.insert(Int.random(in: 1...1000000))
        }
        let idArray = Array(uniqueIds)
        
        for index in 0..<count {
            let id = idArray[index]
            let title = "원하는 콘텐츠 \(id)"
            let thumbnailIUrl = "mock_small_thumbnail"
            
            let entity = WishListEntity(
                id: id,
                title: title,
                thumbnailIUrl: thumbnailIUrl
            )
            results.append(entity)
        }
        
        return results
    }
    
    // MARK: - PurchasedContent용 MOCK 데이터 생성 (id를 난수로 설정)
    private func generateRandomPurchasedList() -> [PurchasedContentEntity] {
        let count = Int.random(in: 10...100)
        var results: [PurchasedContentEntity] = []
        
        // 1) 중복 없는 난수 ID 세트 생성 (1...10000 범위)
        var uniqueIds = Set<Int>()
        while uniqueIds.count < count {
            uniqueIds.insert(Int.random(in: 1...1000000))
        }
        let idArray = Array(uniqueIds)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        let oneYearInSeconds: TimeInterval = 365 * 24 * 60 * 60
        
        for index in 0..<count {
            let id = idArray[index]
            let title = "구매한 콘텐츠 \(id)"
            let thumbnailIUrl = "mock_small_thumbnail"
            let totalEpisodeCount = Int.random(in: 1...50)
            let watchedEpisode = Int.random(in: 1...totalEpisodeCount)
            let randomOffset = TimeInterval.random(in: 0...oneYearInSeconds)
            let randomDate = Date().addingTimeInterval(-randomOffset)
            let watchedDate = dateFormatter.string(from: randomDate)
            
            let entity = PurchasedContentEntity(
                id: id,
                title: title,
                thumbnailIUrl: thumbnailIUrl,
                watchedEpisode: watchedEpisode,
                totalEpisodeCount: totalEpisodeCount,
                watchedDate: watchedDate
            )
            results.append(entity)
        }
        
        return results
    }
    
}
