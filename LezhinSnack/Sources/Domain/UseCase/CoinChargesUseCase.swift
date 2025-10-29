//
//  CoinChargesUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 10/1/25.
//

protocol CoinChargesUseCaseProtocol {
    func executeFetchCoinCharges(page: Int, size: Int, filter: CoinChargeFilter) async throws -> PagedEntity<CoinChargeEntity>
}

final class CoinChargesUseCase: CoinChargesUseCaseProtocol {
    private let repository: HistoryRepositoryProtocol
    init(repository: HistoryRepositoryProtocol) { self.repository = repository }

    func executeFetchCoinCharges(page: Int, size: Int, filter: CoinChargeFilter) async throws -> PagedEntity<CoinChargeEntity> {
        try await repository.fetchCoinCharges(page: page, size: size, filter: filter)
    }
}
