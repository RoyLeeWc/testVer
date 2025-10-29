//
//  InAppPurchaseUseCase.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/20/25.
//

protocol InAppPurchaseUseCaseProtocol {
    
    /// 소모성 인앱 결제 상품 정보
    func executeFetchCoinProduct() async throws -> [CoinProductEntity]
    
    /// 구독형 인앱 결제 상품 정보
    func executeFetchMembershipProduct() async throws -> [MembershipProductEntity]
    
    /// 소모성 인앱 결제 진행
    func executePurchase(paymentInfo: PurchaseUserContext) async throws -> Result<InAppPurchaseEntity, PurchaseError>
    
    /// 구독형 상품 결제 진행
    func executeSubscriptionPurchase(paymentInfo: PurchaseUserContext) async -> Result<InAppPurchaseEntity, PurchaseError>
    
    /// 인앱결제 끝나지 않은 트랜잭션 검사
    func executeCheckUnfinishedTransaction() async throws -> InAppPurchaseEntity?
    
}

class InAppPurchaseUseCase: InAppPurchaseUseCaseProtocol {

    private let repository: InAppPurchaseRepositoryProtocol
    
    init(inAppPurchaseRepository: InAppPurchaseRepositoryProtocol) {
        self.repository = inAppPurchaseRepository
    }
    
    func executePurchase(paymentInfo: PurchaseUserContext) async -> Result<InAppPurchaseEntity, PurchaseError> {
        do {
            let result = try await repository.purchaseProduct(paymentInfo: paymentInfo)
            
            return .success(result)  // InAppPurchaseEntity 반환
        } catch let error as PurchaseError {
            return .failure(error)   // 커스텀 에러로 반환
        } catch {
            return .failure(.unknownError)
        }
    }
    func executeSubscriptionPurchase(paymentInfo: PurchaseUserContext) async -> Result<InAppPurchaseEntity, PurchaseError> {
        do {
            let result = try await repository.purchaseSubscription(paymentInfo: paymentInfo)
            
            return .success(result)  // InAppPurchaseEntity 반환
        } catch let error as PurchaseError {
            return .failure(error)   // 커스텀 에러로 반환
        } catch {
            return .failure(.unknownError)
        }
        
    }
    
//    func executePurchase(paymentInfo: PaymentInfoDTO) async -> Result<InAppPurchaseEntity, PurchaseError> {
//        do {
//            let result = try await repository.purchaseProduct(paymentInfo: paymentInfo)
//
//            return .success(result)  // InAppPurchaseEntity 반환
//        } catch let error as PurchaseError {
//            return .failure(error)   // 커스텀 에러로 반환
//        } catch {
//            return .failure(.unknownError)
//        }
//    }

    
    
//    func executeSubscriptionPurchase(paymentInfo: PaymentInfoDTO) async throws {
//        try await repository.purchaseSubscription(paymentInfo: paymentInfo)
//    }
    
    func executeFetchCoinProduct() async throws -> [CoinProductEntity] {
        return try await repository.fetchCoinProduct()
    }
    
    func executeFetchMembershipProduct() async throws -> [MembershipProductEntity] {
        return try await repository.fetchMembershipProduct()
    }
    
    func executeCheckUnfinishedTransaction() async throws -> InAppPurchaseEntity? {
        return try await repository.checkUnfinishedTransaction()
    }
    
}



