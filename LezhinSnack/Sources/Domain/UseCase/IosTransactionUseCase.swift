//
//  IosTransactionUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 10/22/25.
//

protocol IosTransactionUseCaseProtocol {
    func submit(
        tradeId: String,
        transactionId: String,
        environment: String,  // "SANDBOX" | "PRODUCTION"
        isSubscription: Bool?
    ) async throws -> IosTransactionEntity
}

final class IosTransactionUseCase: IosTransactionUseCaseProtocol {
    private let repo: InAppPurchaseRepositoryProtocol
    init(repository: InAppPurchaseRepositoryProtocol) { self.repo = repository }

    func submit(
        tradeId: String,
        transactionId: String,
        environment: String,
        isSubscription: Bool?
    ) async throws -> IosTransactionEntity {
        try await repo.submitIosTransaction(
            tradeId: tradeId,
            transactionId: transactionId,
            environment: environment,
            isSubscription: isSubscription
        )
    }
}
