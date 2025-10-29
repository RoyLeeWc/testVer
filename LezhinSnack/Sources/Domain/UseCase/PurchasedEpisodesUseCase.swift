//
//  FetchPurchasedEpisodesUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 9/25/25.
//

protocol PurchasedEpisodesUseCaseProtocol {
    func executeFetchPurchasedEpisodes(contentsId: String) async throws -> [PurchasedEpisodeEntity]
}

final class PurchasedEpisodesUseCase: PurchasedEpisodesUseCaseProtocol {
    private let repository: ContentsRepositoryProtocol
    init(repository: ContentsRepositoryProtocol) { self.repository = repository }

    func executeFetchPurchasedEpisodes(contentsId: String) async throws -> [PurchasedEpisodeEntity] {
        try await repository.fetchPurchasedEpisodes(contentsId: contentsId)
    }
}
