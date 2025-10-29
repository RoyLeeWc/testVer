//
//  PaymentProvidersUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 10/22/25.
//

protocol PaymentProvidersUseCaseProtocol {
    func fetchPaymentProviders(paymentMenuType: String) async throws -> [PaymentProviderEntity]
}
final class PaymentProvidersUseCase: PaymentProvidersUseCaseProtocol {
    private let repo: InAppPurchaseRepositoryProtocol
    init(repository: InAppPurchaseRepositoryProtocol) { self.repo = repository }
    
    func fetchPaymentProviders(paymentMenuType: String) async throws -> [PaymentProviderEntity] {
        try await repo.fetchPaymentProviders(paymentMenuType: paymentMenuType)
    }
}
