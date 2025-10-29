//
//  FetchEpisodeMetaUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 9/18/25.
//

protocol FetchEpisodeMetaUseCaseProtocol {
    func executeFetchEpisodeMeta(contentsAlias: String, episodeAlias: String) async throws -> DisplayEpisodeEntity
}

final class FetchEpisodeMetaUseCase: FetchEpisodeMetaUseCaseProtocol {
    private let repo: ContentsRepositoryProtocol
    init(repo: ContentsRepositoryProtocol) { self.repo = repo }

    func executeFetchEpisodeMeta(contentsAlias: String, episodeAlias: String) async throws -> DisplayEpisodeEntity {
        try await repo.fetchEpisodeMeta(contentsAlias: contentsAlias, episodeAlias: episodeAlias)
    }
}
