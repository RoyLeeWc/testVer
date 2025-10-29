//
//  IAPBottomSheetViewModel.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/5/25.
//


import Combine

final class IAPBottomSheetViewModel {

    deinit {
        printX("메모리 해제")
    }
    
    private let useCase: InAppPurchaseUseCaseProtocol
    private let productsuseCase: ProductsUseCaseProtocol
    private let paymentProvidersuseCase: PaymentProvidersUseCaseProtocol
    
    @Published var coinProductList: [ProductItemEntity] = []
    @Published var memberShipProductList: [ProductItemEntity] = []
    // 첫결제 대상 id 집합
    @Published private(set) var firstPurchaseCoinIds: Set<Int> = []
    
    @Published var footerTextList: [ShopFooterEntity]?
    @Published var purchaseViewState: PurchaseViewState = .idle
    
    init(inAppPurchaseUseCase: InAppPurchaseUseCaseProtocol,
         productsuseCase: ProductsUseCaseProtocol,
         paymentProvidersuseCase: PaymentProvidersUseCaseProtocol) {
        self.useCase = inAppPurchaseUseCase
        self.productsuseCase = productsuseCase
        self.paymentProvidersuseCase = paymentProvidersuseCase
       
    }
    
    
    func jsApplePurchase( purchaseStringData: String ) {
        if let decodeData: PaymentInfoDTO = purchaseStringData.decode(to: PaymentInfoDTO.self) {
            printX(decodeData)
        } else {
            // 에러 처리 로직 (필요시)
        }
    }
    
    func makeFooterText() -> [ShopFooterEntity] {
        return [
            ShopFooterEntity(texts: [
                "결제/환불 등에 관한 유의사항 등의 안내 문구 구성 주의사항과 유의사항은 강제성 부분에서 차이가 있다.",
                "결제/환불 등에 관한 유의사항 등의 안내 문구 구성 주의사항과 유의사항은 강제성 부분에서 차이가 있다.결제/환불 등에 관한 유의사항 등의 안내 문구 구성 주의사항과 유의사항은 강제성 부분에서 차이가 있다.",
                "결제/환불 등에 관한 유의사항 등의 안내 문구 구성 주의사항과 유의사항은 강제성 부분에서 차이가 있다.결제/환불 등에 관한 유의사항 등의 안내 문구 구성 주의사항과 유의사항은 강제성 부분에서 차이가 있다.결제/환불 등에 관한 유의사항 등의 안내 문구 구성 주의사항과 유의사항은 강제성 부분에서 차이가 있다."
            ])
        ]
    }
    
    func purchaseConsumable(paymentInfo: PaymentInfoDTO) throws {
//        LZSnackConcurrencyManager.run { [weak self] in
//            guard let self = self else { return }
//            self.purchaseViewState = .loading
//            let result = try await useCase.executePurchase(paymentInfo: paymentInfo)
//            switch result {
//            case .success(let entity):
//                self.purchaseViewState = .success(entity)
//            case .failure(let purchaseError):
//                self.purchaseViewState = .failure(purchaseError)
//            }
//        }
    }
    
    
    func checkUnfinishedTransaction() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self = self else { return }
            guard let result = try await useCase.executeCheckUnfinishedTransaction() else { return }
            self.purchaseViewState = .success(result)
        }
    }
    
    
    func purchaseSubscription(paymentInfo: PaymentInfoDTO) throws {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self = self else { return }
//            try await useCase.executeSubscriptionPurchase(paymentInfo: paymentInfo)
        }
    }
    
    
    func fetchProduct() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            do {
                
                let catalog = try await self.productsuseCase.fetchProducts()
                
                // 코인(소모형): iOS + ONE_TIME_PURCHASE
                let coins = catalog?.coinProductCatalogs
                    .filter { $0.paymentMenuType == .coinProduct }
                    .flatMap { $0.products }
                    .filter { $0.isIOSConsumable }
                
                // 구독: iOS
                let subs = catalog?.subscriptionProductCatalogs
                    .filter { $0.paymentMenuType == .subscriptionProduct }
                    .flatMap { $0.products }
                    .filter { $0.platforms.contains("IOS") }
                
                self.coinProductList = coins ?? []
                self.memberShipProductList = subs ?? []
                
                let firstType: Set<String> = ["FIRST_CHARGE"].map { $0.uppercased() }.reduce(into: Set<String>()) { $0.insert($1) }
                
                let coinFirstIds = catalog?.coinProductCatalogs
                    .filter { firstType.contains($0.catalogType.uppercased()) }
                    .flatMap { $0.products.map(\.productId) }
                self.firstPurchaseCoinIds = Set(coinFirstIds ?? [])
                
            } catch {
                // TODO: 에러 처리
            }
        }
    }
    
//    func fetchMembershipProduct() {
//        LZSnackConcurrencyManager.run { [weak self] in
//            guard let self = self else { return }
//            self.memberShipProductList = try await useCase.executeFetchMembershipProduct()
//        }
//    }
    
    
}
