//
//  PaymentDetailUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 10/10/25.
//

protocol PaymentDetailUseCaseProtocol {
    func executeFetchPaymentDetail(transactionId: String) async throws -> PaymentDetailEntity
}
final class PaymentDetailUseCase: PaymentDetailUseCaseProtocol {
    private let repository: HistoryRepositoryProtocol
    init(repository: HistoryRepositoryProtocol) { self.repository = repository }
    
    func executeFetchPaymentDetail(transactionId: String) async throws -> PaymentDetailEntity {
        try await repository.fetchPaymentDetail(transactionId: transactionId)
    }
}
