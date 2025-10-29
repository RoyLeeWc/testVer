//
//  FavoriteContentsMyListUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 10/13/25.
//


protocol WishContentsMyListUseCaseProtocol {
    func executeFavoriteContentsMyList(size: Int, page: Int, sort: ContentsListSort, isPaged: Bool?) async throws -> WishContentsPageEntity
}

final class WishContentsMyListUseCase: WishContentsMyListUseCaseProtocol {
    private let repository: MyListRepositoryProtocol
    init(repository: MyListRepositoryProtocol) { self.repository = repository }

    func executeFavoriteContentsMyList(size: Int, page: Int, sort: ContentsListSort, isPaged: Bool?) async throws -> WishContentsPageEntity {
        try await repository.fetchWishList(size: size, page: page, sort: sort, isPaged: isPaged)
    }
}
