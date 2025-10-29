//
//  PurchaseRepository.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/20/25.
//

import StoreKit

enum PurchaseError: Error {
    
    /// 소모성 거래 에러
    case invalidPayment
    case transactionVerificationFailed
    case invalidRedirectUrlString
    case networkRequestError(Error)
    case networkResponseError(Error)
    case userCancel
    case pending
    case alreadyRequestCoinCharge
    case unknownError
    case productLimitCountError(String)
    
    
    ///구독 거래 에러
    
    case alreadyRequestSubscription
    case invalidSubscription
    case subscriptionNotActive
    
}

protocol InAppPurchaseRepositoryProtocol {
    
    func fetchCoinProduct() async throws -> [CoinProductEntity]
    
    func fetchMembershipProduct() async throws -> [MembershipProductEntity]
    
    /// 소모성 상품 구매결과
    func purchaseProduct(paymentInfo: PaymentInfoDTO) async throws -> InAppPurchaseEntity
        
    /// 구독형 상품 구매결과
    func purchaseSubscription(paymentInfo: PaymentInfoDTO) async throws -> InAppPurchaseEntity
    
    
    /// 끝나지 않은 트랜잭션 검사
    func checkUnfinishedTransaction() async throws -> InAppPurchaseEntity?
}


class InAppPurchaseRepository: InAppPurchaseRepositoryProtocol {
    
    func fetchCoinProduct() async throws -> [CoinProductEntity] {
        
        var coinProducts: [CoinProductEntity] = []
        
        for index in 1...4 {
            coinProducts.append(CoinProductEntity(id: index,
                                                  coinValue: "200",
                                                  originalPrice: Double((5000 * index)),
                                                  salePersentage: 50.0,
                                                  salePrice: Double((5000 * index)),
                                                  isFirstPurchase: Bool.random()))
        }
        
        return coinProducts
    }
    
    func fetchMembershipProduct() async throws -> [MembershipProductEntity] {
        var memebershipProducts: [MembershipProductEntity] = []
        
        for index in 1...2 {
            var membershipType: String = ""
            if index % 2 == 0 {
                membershipType = "annualSubscription"
            } else {
                membershipType = "monthlySubscription"
            }
            
            memebershipProducts.append(MembershipProductEntity(id: index,
                                                               membershipType: membershipType,
                                                               originalPrice: Double((5000 * index)),
                                                               salePersentage: 50.0,
                                                               salePrice: Double((5000 * index)),
                                                               isBestProducts: Bool.random()))
        }
        return memebershipProducts
    }
    
    
    func purchaseProduct(paymentInfo: PaymentInfoDTO) async throws -> InAppPurchaseEntity {
        return try await InAppPurchaseService.shared.purchaseNewConsumableProduct(paymentInfo: paymentInfo)
        
//        return try await mockSubscriptionPurchase()
    }
    
    func purchaseSubscription(paymentInfo: PaymentInfoDTO) async throws -> InAppPurchaseEntity {
        return InAppPurchaseEntity(inAppPurchaseType: .annual,
                                   amount: 9900,
                                   purchaseDate: LZSUtil.getCurrentTimeDate(),
                                   purchaseCoin: nil,
                                   purchasePeriod: LZSUtil.getCurrentTimeString(),
                                   paymentMethod: "충전소_결제수단_애플인앱".localized)
    }
    
    
    func checkUnfinishedTransaction() async throws -> InAppPurchaseEntity? {
        if InAppPurchaseService.shared.isPurchasing == false {
            return try await InAppPurchaseService.shared.processConsumableTransaction()
        } else {
            throw PurchaseError.alreadyRequestCoinCharge
        }
    }
    
    
    private func mockSubscriptionPurchase() async throws -> InAppPurchaseEntity {
        
        //let productID = "com.lezhin.snack.subscription.monthly"
        
        let productID = "com.lezhin.snack.subscription.annual"
        
        let products = try await Product.products(for: [productID])
        guard let product = products.first else {
            throw PurchaseError.invalidSubscription
        }
        
        let purchaseResult = try await product.purchase()
        
        switch purchaseResult {
        case let .success(.verified(transaction)):
            await transaction.finish()
            return InAppPurchaseEntity(inAppPurchaseType: .annual,
                                       amount: 9900,
                                       purchaseDate: LZSUtil.getCurrentTimeDate(),
                                       purchaseCoin: nil,
                                       purchasePeriod: LZSUtil.getCurrentTimeString(),
                                       paymentMethod: "충전소_결제수단_애플인앱".localized)
        case .userCancelled:
            throw PurchaseError.userCancel
        case .pending:
            throw PurchaseError.pending
        @unknown default:
            throw PurchaseError.unknownError
        }
    }
}
