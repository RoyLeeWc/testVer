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


enum InAppPurchaseRepositoryError: Error {
    case api(code: String, message: String)
    case invalidData
}

protocol InAppPurchaseRepositoryProtocol {
    
    func fetchCoinProduct() async throws -> [CoinProductEntity]
    
    func fetchMembershipProduct() async throws -> [MembershipProductEntity]
    
    /// 소모성 상품 구매결과
    func purchaseProduct(paymentInfo: PurchaseUserContext) async throws -> InAppPurchaseEntity
        
    /// 구독형 상품 구매결과
    func purchaseSubscription(paymentInfo: PurchaseUserContext) async throws -> InAppPurchaseEntity
    
    
    /// 끝나지 않은 트랜잭션 검사
    func checkUnfinishedTransaction() async throws -> InAppPurchaseEntity?
    
    
    
    ///--------------------
    func fetchPaymentProviders(paymentMenuType: String) async throws -> [PaymentProviderEntity]
    
    func reserveAppPayment(
        accessToken: String,
        countryCode: String,
        ipAddress: String,
        languageType: String,
        paymentMenuType: String,
        paymentProviderId: Int,
        productId: Int?,
        platform: String
    ) async throws -> AppPaymentReserveEntity
    
    func submitIosTransaction(
        tradeId: String,
        transactionId: String,
        environment: String,
        isSubscription: Bool?
    ) async throws -> IosTransactionEntity
    
    func fetchProducts() async throws -> CoinProductsEntity
    
}


class InAppPurchaseRepository: InAppPurchaseRepositoryProtocol {
    
    func fetchProducts() async throws -> CoinProductsEntity {
        let req = CoinProductsAPIRequest()
        let dto: CoinProductsDTO = try await NetworkService.shared.requestAsync(req)
        
        guard dto.responseCode == "SUCCESS" else {
            let msg = dto.errorData?.defaultMessage ?? "실패"
            throw InAppPurchaseRepositoryError.api(code: dto.errorData?.code ?? "ERROR", message: msg)
        }
        guard let data = dto.data else {
            throw InAppPurchaseRepositoryError.invalidData
        }
        return data.toEntity()
    }
    
    func submitIosTransaction(
        tradeId: String,
        transactionId: String,
        environment: String,
        isSubscription: Bool?
    ) async throws -> IosTransactionEntity {
        let req = IosTransactionAPIRequest(
            tradeId: tradeId,
            transactionId: transactionId,
            environment: environment,
            isSubscription: isSubscription
        )
        let dto: IosTransactionDTO = try await NetworkService
            .shared.requestAsync(req)
        
        guard dto.responseCode == "SUCCESS", let data = dto.data else {
            let msg = dto.errorData?.defaultMessage ?? "실패"
            throw InAppPurchaseRepositoryError.api(code: dto.errorData?.code ?? "ERROR", message: msg)
        }
        return data.toEntity()
    }
    
    func fetchPaymentProviders(paymentMenuType: String) async throws -> [PaymentProviderEntity] {
        let req = PaymentProvidersAPIRequest(paymentMenuType: paymentMenuType)
        let dto: PaymentProviderDTO = try await NetworkService.shared.requestAsync(req)
        guard dto.responseCode == "SUCCESS" else {
            let msg = dto.errorData?.defaultMessage ?? "실패"
            throw InAppPurchaseRepositoryError.api(code: dto.errorData?.code ?? "ERROR", message: msg)
        }
        return (dto.data ?? []).map { $0.toEntity() }
    }
    
    func reserveAppPayment(
        accessToken: String,
        countryCode: String,
        ipAddress: String,
        languageType: String,
        paymentMenuType: String,
        paymentProviderId: Int,
        productId: Int?,
        platform: String
    ) async throws -> AppPaymentReserveEntity {
        let req = AppPaymentReserveAPIRequest(
            accessToken: accessToken,
            countryCode: countryCode,
            ipAddress: ipAddress,
            languageType: languageType,
            paymentMenuType: paymentMenuType,
            paymentProviderId: paymentProviderId,
            productId: productId,
            platform: platform
        )
        let dto: AppPaymentReserveDTO = try await NetworkService.shared.requestAsync(req)
        guard dto.responseCode == "SUCCESS", let data = dto.data else {
            let msg = dto.errorData?.defaultMessage ?? "실패"
            throw InAppPurchaseRepositoryError.api(code: dto.errorData?.code ?? "ERROR", message: msg)
        }
        return data.toEntity()
    }
    
    ///--------------------
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
    
    
    func purchaseProduct(paymentInfo: PurchaseUserContext) async throws -> InAppPurchaseEntity {
        return try await InAppPurchaseService.shared.purchaseNewConsumableProduct(paymentInfo: paymentInfo)
        
//        return try await mockSubscriptionPurchase()
    }
    
    func purchaseSubscription(paymentInfo: PurchaseUserContext) async throws -> InAppPurchaseEntity {
        return try await InAppPurchaseService.shared.purchaseNewSubscription(paymentInfo: paymentInfo)
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
