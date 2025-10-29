//
//  FetchPreviewRecommendationsUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 9/18/25.
//

protocol FetchPreviewRecommendationsUseCaseProtocol {
    func executeFetchPreviewRecommendations() async throws -> PreviewRecommendationEntity
}

final class FetchPreviewRecommendationsUseCase: FetchPreviewRecommendationsUseCaseProtocol {
    private let repo: ContentsRepositoryProtocol
    init(repo: ContentsRepositoryProtocol) { self.repo = repo }

    func executeFetchPreviewRecommendations() async throws -> PreviewRecommendationEntity {
        try await repo.fetchPreviewRecommendations()
    }
}
