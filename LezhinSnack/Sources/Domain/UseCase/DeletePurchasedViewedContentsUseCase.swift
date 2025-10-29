//
//  DeletePurchasedViewedContentsUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 10/14/25.
//

protocol DeletePurchasedViewedContentsUseCaseProtocol {
    func executeDeletePurchasedViewedContentsMyList(contentsIds: [String]) async throws
}

final class DeletePurchasedViewedContentsUseCase: DeletePurchasedViewedContentsUseCaseProtocol {
    private let repository: MyListRepositoryProtocol
    init(repository: MyListRepositoryProtocol) { self.repository = repository }

    func executeDeletePurchasedViewedContentsMyList(contentsIds: [String]) async throws {
        try await repository.deletePurchasedList(contentsIds: contentsIds)
    }
}
