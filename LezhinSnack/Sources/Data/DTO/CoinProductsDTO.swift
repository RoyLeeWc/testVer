//
//  CoinProductsDTO.swift
//  LezhinSnack
//
//  Created by lwc on 10/22/25.
//

import Foundation

struct CoinProductsDTO: Decodable {
    let responseCode: String
    let data: CoinProductsDataDTO?
    let errorData: ErrorDataDTO?
}

struct CoinProductsDataDTO: Decodable {
    let coinProductCatalogs: [ProductCatalogDTO]
    let subscriptionProductCatalogs: [ProductCatalogDTO]
}

struct ProductCatalogDTO: Decodable {
    let catalogId: Int
    let catalogType: String             // "RECHARGE" 등
    let paymentMenuType: String         // "COIN_PRODUCT"
    let products: [ProductItemDTO]
}

struct ProductItemDTO: Decodable {
    let productId: Int
    let productLanguageId: Int
    let displayTitle: String
    let description: String
    let coin: Int
    let coinExpiredPeriod: Int
    let bonusCoin: Int?
    let bonusCoinExpiredPeriod: Int?
    let price: Int
    let periodType: String              // "ONE_TIME_PURCHASE", ...
    let discountPrice: Int?
    let currencyType: String            // "KRW" 등
    let productCode: String
    let isBest: Bool
    let platforms: [String]             // ["WEB","IOS","ANDROID"]
}

extension CoinProductsDataDTO {
    func toEntity() -> CoinProductsEntity {
        .init(
            coinProductCatalogs: coinProductCatalogs.map { $0.toEntity() },
            subscriptionProductCatalogs: subscriptionProductCatalogs.map { $0.toEntity() }
        )
    }
}

extension ProductCatalogDTO {
    func toEntity() -> ProductCatalogEntity {
        .init(
            catalogId: catalogId,
            catalogType: catalogType,
            paymentMenuType: PaymentMenuType(rawValue:paymentMenuType),
            products: products.map { $0.toEntity() }
        )
    }
}

extension ProductItemDTO {
    func toEntity() -> ProductItemEntity {
        .init(
            productId: productId,
            productLanguageId: productLanguageId,
            displayTitle: displayTitle,
            description: description,
            coin: coin,
            coinExpiredPeriod: coinExpiredPeriod,
            bonusCoin: bonusCoin,
            bonusCoinExpiredPeriod: bonusCoinExpiredPeriod,
            price: price,
            periodType: periodType,
            discountPrice: discountPrice,
            currencyType: currencyType,
            productCode: productCode,
            isBest: isBest,
            platforms: platforms
        )
    }
}

