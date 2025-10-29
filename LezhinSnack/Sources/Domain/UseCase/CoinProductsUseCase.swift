//
//  ProductsUseCaseProtocol.swift
//  LezhinSnack
//
//  Created by lwc on 10/22/25.
//

import Foundation

protocol ProductsUseCaseProtocol {
    func fetchProducts() async throws -> CoinProductsEntity?
    func fetchCoinProductItems() async throws -> [ProductItemEntity]
    func fetchSubscriptionProductItems() async throws -> [ProductItemEntity]
}

final class ProductsUseCase: ProductsUseCaseProtocol {
    private let repository: InAppPurchaseRepositoryProtocol
    init(repository: InAppPurchaseRepositoryProtocol) { self.repository = repository }
    
    func fetchProducts() async throws -> CoinProductsEntity? {
        try await repository.fetchProducts()
    }
    
    func fetchCoinProductItems() async throws -> [ProductItemEntity] {
        let entity = try await repository.fetchProducts()
        return entity.coinProductCatalogs.flatMap { $0.products } ?? []
    }
    
    func fetchSubscriptionProductItems() async throws -> [ProductItemEntity] {
        let entity = try await repository.fetchProducts()
        return entity.subscriptionProductCatalogs.flatMap { $0.products } ?? []
    }
}
