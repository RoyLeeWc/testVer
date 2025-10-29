//
//  MyListRepository.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/4/25.
//

import Foundation



protocol MyListRepositoryProtocol {
    func fetchWatchList() async throws -> [WatchHistoryEntity]
//    func fetchWishList() async throws -> [WishListEntity]
    func fetchPurchasedList() async throws -> [PurchasedContentEntity]

    
    
    
    func fetchLastViewedContents( size: Int, page: Int, sort: ContentsListSort, isPaged: Bool?) async throws -> LastViewedContentsPageEntity
    
    func fetchWishList(size: Int, page: Int, sort: ContentsListSort, isPaged: Bool?) async throws -> WishContentsPageEntity
    
    func fetchPurchasedContents(size: Int, page: Int, sort: ContentsListSort, isPaged: Bool?) async throws -> PurchasedContentsPageEntity
    
    
    func deleteWatchList(contentsIds: [String]) async throws
    
    func deleteWishList(contentsIds: [String]) async throws
    
    func deletePurchasedList(contentsIds: [String]) async throws
    
}

enum MyListRepositoryError: Error {
    case api(code: String, message: String)
}


final class MyListRepository: MyListRepositoryProtocol {
    
    func fetchWishList(size: Int, page: Int, sort: ContentsListSort, isPaged: Bool? = true) async throws -> WishContentsPageEntity {
        let req = WishContentsAPIRequest(size: size, page: page, sort: sort, isPaged: isPaged)
        let dto: WishContentsDTO = try await NetworkService.shared.requestAsync(req)
        
        guard dto.responseCode == APIResultType.success, let data = dto.data else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "Fetch favorite contents failed."
            throw MyListRepositoryError.api(code: code, message: msg)
        }
        
        func msToDate(_ data: Int64) -> Date {
            return Date(timeIntervalSince1970: TimeInterval(data) / 1000.0)
        }
        
        let items: [WishContentItemEntity] = (data.content ?? []).map {
            WishContentItemEntity(
                contentsId: $0.contentsId ?? "",
                lastFavoriteEpisodeId: $0.lastFavoriteEpisodeId,
                title: $0.title ?? "",
                isNewEpisode: $0.isNewEpisode ?? false,
                lastFavoriteAt: msToDate($0.lastFavoriteAt),
                thumbnailUrl: $0.thumbnailUrl,
                contentsAlias: $0.contentsAlias
            )
        }
        
        return WishContentsPageEntity(
            items: items,
            pageNumber: data.pageable?.pageNumber ?? 0,
            pageSize: data.pageable?.pageSize ?? items.count,
            totalElements: data.totalElements ?? items.count,
            totalPages: data.totalPages ?? 1,
            isFirst: data.first ?? (data.pageable?.pageNumber ?? 0 == 0),
            isLast: data.last ?? true,
            numberOfElements: data.numberOfElements ?? items.count,
            isEmpty: data.empty ?? items.isEmpty
        )
    }
    
    func fetchLastViewedContents( size: Int, page: Int, sort: ContentsListSort, isPaged: Bool? = true) async throws -> LastViewedContentsPageEntity {
        let req = LastViewedContentsAPIRequest(size: size, page: page, sort: sort, isPaged: isPaged)
        let dto: LastViewedContentsDTO = try await NetworkService.shared.requestAsync(req)
        
        guard dto.responseCode == APIResultType.success, let data = dto.data else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "Fetch last-viewed contents failed."
            throw MyListRepositoryError.api(code: code, message: msg)
        }
        
        func msToDate(_ data: Int64) -> Date {
            return Date(timeIntervalSince1970: TimeInterval(data) / 1000.0)
        }
        
        let items: [LastViewedContentItemEntity] = (data.content ?? []).map {
            LastViewedContentItemEntity(
                contentsId: $0.contentsId,
                lastViewedEpisodeId: $0.lastViewedEpisodeId,
                title: $0.title ?? "",
                lastViewedEpisodeNumber: $0.lastViewedEpisodeNumber,
                lastEpisodeNumber: $0.lastEpisodeNumber,
                isNewEpisode: $0.isNewEpisode ?? false,
                lastViewedAt: msToDate($0.lastViewedAt),
                thumbnailUrl: $0.thumbnailUrl,
                contentsAlias: $0.contentsAlias
            )
        }
        
        return LastViewedContentsPageEntity(
            items: items,
            pageNumber: data.pageable?.pageNumber ?? 0,
            pageSize: data.pageable?.pageSize ?? items.count,
            totalElements: data.totalElements ?? items.count,
            totalPages: data.totalPages ?? 1,
            isFirst: data.first ?? (data.pageable?.pageNumber ?? 0 == 0),
            isLast: data.last ?? true,
            numberOfElements: data.numberOfElements ?? items.count,
            isEmpty: data.empty ?? items.isEmpty
        )
    }
    
    func fetchPurchasedContents(size: Int, page: Int, sort: ContentsListSort, isPaged: Bool? = true) async throws -> PurchasedContentsPageEntity {
        let req = PurchasedContentsAPIRequest(size: size, page: page, sort: sort, isPaged: isPaged)
        let dto: PurchasedContentsDTO = try await NetworkService.shared.requestAsync(req)
        
        guard dto.responseCode == APIResultType.success,
              let data = dto.data
        else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "Fetch purchased contents failed."
            throw MyListRepositoryError.api(code: code, message: msg)
        }
        
        func msToDate(_ ms: Int64) -> Date {
            return Date(timeIntervalSince1970: TimeInterval(ms) / 1000.0)
        }
        
        let items: [PurchasedContentItemEntity] = (data.content ?? []).map {
            PurchasedContentItemEntity(
                contentsId: $0.contentsId ?? "",
                lastViewedEpisodeId: $0.lastViewedEpisodeId ?? "",
                title: $0.title ?? "",
                purchasedEpisodeCount: $0.purchasedEpisodeCount ?? 0,
                lastPurchasedAt: msToDate($0.lastPurchasedAt),
                thumbnailUrl: $0.thumbnailUrl,
                contentsAlias: $0.contentsAlias,
                isNewEpisode: $0.isNewEpisode
            )
        }
        
        return PurchasedContentsPageEntity(
            items: items,
            pageNumber: data.pageable?.pageNumber ?? 0,
            pageSize: data.pageable?.pageSize ?? 0,
            totalElements: data.totalElements ?? items.count,
            totalPages: data.totalPages ?? 1,
            isFirst: data.first ?? (data.pageable?.pageNumber ?? 0 == 0),
            isLast: data.last ?? true,
            numberOfElements: data.numberOfElements ?? items.count,
            isEmpty: data.empty ?? items.isEmpty
        )
    }
    
    func deleteWatchList(contentsIds: [String]) async throws {
        let req = LastViewedBulkDeleteAPIRequest(contentsIds: contentsIds)
        let dto: EmptyResponseDTO = try await NetworkService.shared.requestAsync(req)
        guard dto.responseCode == APIResultType.success else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "최근 찜 목록 삭제에 실패했습니다."
            throw MyListRepositoryError.api(code: code, message: msg)
        }
    }
    
    func deleteWishList(contentsIds: [String]) async throws {
        let req = WishViewedBulkDeleteAPIRequest(contentsIds: contentsIds)
        let dto: EmptyResponseDTO = try await NetworkService.shared.requestAsync(req)
        guard dto.responseCode == APIResultType.success else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "최근 시청 목록 삭제에 실패했습니다."
            throw MyListRepositoryError.api(code: code, message: msg)
        }
    }
    
    func deletePurchasedList(contentsIds: [String]) async throws {
        let req = PurchasedViewedBulkDeleteAPIRequest(contentsIds: contentsIds)
        let dto: EmptyResponseDTO = try await NetworkService.shared.requestAsync(req)
        guard dto.responseCode == APIResultType.success else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "최근 구매 작품 목록 숨기기에 실패했습니다."
            throw MyListRepositoryError.api(code: code, message: msg)
        }
    }
    
    
    func fetchWatchList() async throws -> [WatchHistoryEntity] {
        return generateRandomWatchHistory()
    }
    
    
    func fetchPurchasedList() async throws -> [PurchasedContentEntity] {
        return generateRandomPurchasedList()
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
