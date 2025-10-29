//
//  PaymentHistoryUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 10/10/25.
//

protocol PaymentHistoryUseCaseProtocol {
    func executeFetchUserPayments(page: Int, size: Int) async throws -> PagedEntity<PaymentHistoryEntity>
}
final class PaymentHistoryUseCase: PaymentHistoryUseCaseProtocol {
    private let repository: HistoryRepositoryProtocol
    init(repository: HistoryRepositoryProtocol) { self.repository = repository }
    
    func executeFetchUserPayments(page: Int, size: Int) async throws -> PagedEntity<PaymentHistoryEntity> {
        try await repository.fetchUserPayments(page: page, size: size)
    }
}
