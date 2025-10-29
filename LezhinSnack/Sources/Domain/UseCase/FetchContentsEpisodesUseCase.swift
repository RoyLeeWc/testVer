//
//  FetchContentsEpisodesUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 9/18/25.
//

protocol FetchContentsEpisodesUseCaseProtocol {
    func executeFetchContentsEpisodes(contentsId: String) async throws -> [ContentsEpisodeEntity]
}

final class FetchContentsEpisodesUseCase: FetchContentsEpisodesUseCaseProtocol {
    private let repo: ContentsRepositoryProtocol
    init(repo: ContentsRepositoryProtocol) { self.repo = repo }

    func executeFetchContentsEpisodes(contentsId: String) async throws -> [ContentsEpisodeEntity] {
        try await repo.fetchContentsEpisodes(contentsId: contentsId)
    }
}
