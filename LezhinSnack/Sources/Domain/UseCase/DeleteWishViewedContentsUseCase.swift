//
//  DeleteWishViewedContentsUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 10/14/25.


protocol DeleteWishViewedContentsUseCaseProtocol {
    func executeDeleteWishViewedContentsMyList(contentsIds: [String]) async throws
}

final class DeleteWishViewedContentsUseCase: DeleteWishViewedContentsUseCaseProtocol {
    private let repository: MyListRepositoryProtocol
    init(repository: MyListRepositoryProtocol) { self.repository = repository }

    func executeDeleteWishViewedContentsMyList(contentsIds: [String]) async throws {
        try await repository.deleteWishList(contentsIds: contentsIds)
    }
}
