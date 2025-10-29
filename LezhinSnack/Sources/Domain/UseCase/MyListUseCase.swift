//
//  MyListUseCase.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/4/25.
//


protocol MyListUseCaseProtocol {
    func executeFetchWatchList() async throws -> [WatchHistoryEntity]
    func executeFetchWishList() async throws -> [WishListEntity]
    func executeFetchPurchasedList() async throws -> [PurchasedContentEntity]
    
    func executeDeleteWatchList(items: [WatchHistoryEntity]) async throws
    func executeDeleteWishList(items: [WishListEntity]) async throws
    func executeDeletePurchasedList(items: [PurchasedContentEntity]) async throws
    
    func executeSortWatchList(by: Int)
    func executeSortWishList(by: Int)
    func executeSortPurchasedList(by: Int)
}



final class MyListUseCase: MyListUseCaseProtocol {
    
    private let repository: MyListRepositoryProtocol
    
    init(myListRepositoryProtocol: MyListRepositoryProtocol) {
        self.repository = myListRepositoryProtocol
    }
    
    func executeFetchWatchList() async throws -> [WatchHistoryEntity] {
        return try await repository.fetchWatchList()
    }
    
    func executeFetchWishList() async throws -> [WishListEntity] {
        return try await repository.fetchWishList()
    }
    
    func executeFetchPurchasedList() async throws -> [PurchasedContentEntity] {
        return try await repository.fetchPurchasedList()
    }
    
    func executeDeleteWatchList(items: [WatchHistoryEntity]) async throws {
        
    }
    
    func executeDeleteWishList(items: [WishListEntity]) async throws {
        
    }
    
    func executeDeletePurchasedList(items: [PurchasedContentEntity]) async throws {
        
    }
    
    func executeSortWatchList(by: Int) {
        
    }
    
    func executeSortWishList(by: Int) {
        
    }
    
    func executeSortPurchasedList(by: Int) {
        
    }
    
    
}
