//
//  CoinUsageHistoryUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 10/1/25.
//

protocol CoinUsageHistoryUseCaseProtocol {
    func executeFetchCoinUsage(page: Int, size: Int) async throws -> PagedEntity<CoinUsageEntity>
}

final class CoinUsageHistoryUseCase: CoinUsageHistoryUseCaseProtocol {
    private let repository: HistoryRepositoryProtocol
    init(repository: HistoryRepositoryProtocol) { self.repository = repository }

    func executeFetchCoinUsage(page: Int, size: Int) async throws -> PagedEntity<CoinUsageEntity> {
        try await repository.fetchCoinUsage(page: page, size: size)
    }
}
