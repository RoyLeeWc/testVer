//
//  CoinProductsEntity.swift
//  LezhinSnack
//
//  Created by lwc on 10/22/25.
//

struct CoinProductsEntity: Hashable {
    let coinProductCatalogs: [ProductCatalogEntity]
    let subscriptionProductCatalogs: [ProductCatalogEntity]
}

struct ProductCatalogEntity: Hashable {
    let catalogId: Int
    let catalogType: String
    let paymentMenuType: PaymentMenuType
    let products: [ProductItemEntity]
}

struct ProductItemEntity: Hashable {
    let productId: Int
    let productLanguageId: Int
    let displayTitle: String
    let description: String
    let coin: Int
    let coinExpiredPeriod: Int
    let bonusCoin: Int?
    let bonusCoinExpiredPeriod: Int?
    let price: Int
    let periodType: String
    let discountPrice: Int?
    let currencyType: String
    let productCode: String
    let isBest: Bool
    let platforms: [String]
}

extension ProductItemEntity {
    // 1) iOS 코인(소모형) 여부
    var isIOSConsumable: Bool {
        platforms.contains("IOS") && periodType == "ONE_TIME_PURCHASE"
    }
    
//    // 2) iOS 구독 여부 (카탈로그가 subscriptionProductCatalogs일 때 사용)
//    var isIOSSubscription: Bool {
//        platforms.contains("IOS") && periodType != "MONTHLY"
//        // 필요시 더 구체적인 값으로 조정 (예: "MONTHLY")
//    }
    
    // 3) 화면 파생값
    var coinText: String {
        if let bonus = bonusCoin, bonus > 0 { return "\(coin) + \(bonus)" }
        return "\(coin)"
    }
    
    var expireText: String {
        let days = coinExpiredPeriod / (1000 * 60 * 60 * 24)
        return days > 0 ? "\(days)일 내 사용" : ""
    }
    
    var hasDiscount: Bool {
        guard let d = discountPrice else { return false }
        return d > 0 && d < price
    }
    
    /// 실구매가(할인 적용가 우선)
    var effectivePrice: Int { Int(discountPrice ?? price) }
    
    /// "9900원" 형태(간단 표기; 필요 시 NumberFormatter로 교체)
    var priceTextKRW: String { "\(Int(effectivePrice))원" }
    var strikePriceTextKRW: String? { hasDiscount ? "\(Int(price))원" : nil }
    
    /// 제목 보정
    var displayTitleOrFallback: String {
        displayTitle.isEmpty ? "코인 \(coin)" : displayTitle
    }
    
    /// 할인율 % (정수, 내림). **Int 연산만** 사용해 부동소수 오차/형 변환 이슈 방지.
    /// 예) 9,900 → 7,900 ⇒ (9900-7900)*100/9900 = 20%
    var discountPercentInt: Int {
        guard hasDiscount, price > 0 else { return 0 }
        let numerator = (price - effectivePrice) * 100
        return max(0, numerator / price) // 내림
    }
    
    /// 반올림이 필요하면 이걸 쓰면 됨.
    var discountPercentRoundedInt: Int {
        guard hasDiscount, price > 0 else { return 0 }
        // (a*100 + price/2) / price  => 정수 반올림
        let numerator = (price - effectivePrice) * 100 + price / 2
        return max(0, numerator / price)
    }
}

// MARK: - Enums (Domain)
enum PaymentMenuType: String, Decodable, Hashable {
    case coinProduct         = "COIN_PRODUCT"
    case subscriptionProduct = "SUBSCRIPTION_PRODUCT"
    case coinConversion     = "COIN_CONVERSION"
    case unknown
    
    init(rawValue: String) {
        switch rawValue {
        case "COIN_PRODUCT":         self = .coinProduct
        case "SUBSCRIPTION_PRODUCT": self = .subscriptionProduct
        case "COIN_CONVERSION":      self = .coinConversion
        default:                     self = .unknown
        }
    }
}
