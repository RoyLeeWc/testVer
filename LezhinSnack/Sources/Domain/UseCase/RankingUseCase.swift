//
//  RankingUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 9/10/25.
//

protocol RankingUseCaseProtocol {
    func executeFetchRanking(period: String,
                             topN: Int,
                             type: String) async throws -> [ContentsRankingItemDTO]
}

final class RankingUseCase: RankingUseCaseProtocol {
    private let repository: CurationRepositoryProtocol
    init(rankingrepository: CurationRepositoryProtocol) {
        self.repository = rankingrepository
    }

    func executeFetchRanking(period: String,
                             topN: Int,
                             type: String) async throws -> [ContentsRankingItemDTO] {
        try await repository.fetchRanking(period: period, topN: topN, type: type)
    }
}
