//
//  AppPaymentReserveUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 10/22/25.
//

// AppPaymentReserveUseCase.swift
protocol AppPaymentReserveUseCaseProtocol {
    func reserve(
        accessToken: String,
        countryCode: String,
        ipAddress: String,
        languageType: String,
        paymentMenuType: String,
        paymentProviderId: Int,
        productId: Int?,
        platform: String
    ) async throws -> AppPaymentReserveEntity
}

final class AppPaymentReserveUseCase: AppPaymentReserveUseCaseProtocol {
    private let repo: InAppPurchaseRepositoryProtocol
    init(repository: InAppPurchaseRepositoryProtocol) { self.repo = repository }
    
    func reserve(
        accessToken: String,
        countryCode: String,
        ipAddress: String,
        languageType: String,
        paymentMenuType: String,
        paymentProviderId: Int,
        productId: Int?,
        platform: String
    ) async throws -> AppPaymentReserveEntity {
        try await repo.reserveAppPayment(
            accessToken: accessToken,
            countryCode: countryCode,
            ipAddress: ipAddress,
            languageType: languageType,
            paymentMenuType: paymentMenuType,
            paymentProviderId: paymentProviderId,
            productId: productId,
            platform: platform
        )
    }
}
