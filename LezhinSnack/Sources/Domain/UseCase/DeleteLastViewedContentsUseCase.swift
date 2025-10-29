//
//  DeleteLastViewedContentsUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 10/14/25.
//

protocol DeleteLastViewedContentsUseCaseProtocol {
    func executeDeleteLastWatchViewedContentsMyList(contentsIds: [String]) async throws
}

final class DeleteLastViewedContentsUseCase: DeleteLastViewedContentsUseCaseProtocol {
    private let repository: MyListRepositoryProtocol
    init(repository: MyListRepositoryProtocol) { self.repository = repository }

    func executeDeleteLastWatchViewedContentsMyList(contentsIds: [String]) async throws {
        try await repository.deleteWatchList(contentsIds: contentsIds)
    }
}
