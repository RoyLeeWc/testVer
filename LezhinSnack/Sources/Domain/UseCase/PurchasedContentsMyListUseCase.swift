//
//  FetchPurchasedContentsUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 9/18/25.
//


protocol PurchasedContentsMyListUseCaseProtocol {
    func executeFetchPurchasedContents(size: Int, page: Int, sort: ContentsListSort, isPaged: Bool?) async throws -> PurchasedContentsPageEntity
}

final class PurchasedContentsMyListUseCase: PurchasedContentsMyListUseCaseProtocol {
    private let repository: MyListRepositoryProtocol
    init(repository: MyListRepositoryProtocol) { self.repository = repository }
    
    func executeFetchPurchasedContents(size: Int, page: Int, sort: ContentsListSort, isPaged: Bool?) async throws -> PurchasedContentsPageEntity {
        try await repository.fetchPurchasedContents(size: size , page: page, sort: sort, isPaged: isPaged)
    }
}
