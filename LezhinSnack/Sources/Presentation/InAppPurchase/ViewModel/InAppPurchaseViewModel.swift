//
//  CoinChargeViewModel.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/19/25.
//

import Foundation


enum PurchaseViewState {
    case idle
    case loading
    case success(InAppPurchaseEntity)
    case failure(Error)
}


final class InAppPurchaseViewModel {
    
    deinit {
        printX("메모리 해제")
    }
    
    private let useCase: InAppPurchaseUseCaseProtocol
    private let productsuseCase: ProductsUseCaseProtocol
    private let paymentProvidersuseCase: PaymentProvidersUseCaseProtocol
//    private let appPaymentReserveUseCase: AppPaymentReserveUseCaseProtocol
    
    
    @Published private(set) var coinItems: [ProductItemEntity] = []
    @Published private(set) var subscriptionItems: [ProductItemEntity] = []
    // 첫결제 대상 id 집합
    @Published private(set) var firstPurchaseCoinIds: Set<Int> = []
    
    private var providerIdCache: [PaymentMenuType: Int] = [:]
    
    @Published var coinProductList: [CoinProductEntity]?
    @Published var memberShipProductList: [MembershipProductEntity]?
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
    
    //    func purchaseConsumable(paymentInfo: PaymentInfoDTO) throws {
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
    //    }
    
    func purchaseConsumable(paymentInfo: PurchaseUserContext) throws {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self = self else { return }
            self.purchaseViewState = .loading
        
            if paymentInfo.paymentMenuType == "COIN_PRODUCT" {
                let result = try await useCase.executePurchase(paymentInfo: paymentInfo)
                switch result {
                case .success(let entity):
                    self.purchaseViewState = .success(entity)
                case .failure(let purchaseError):
                    self.purchaseViewState = .failure(purchaseError)
                    onMain { [weak self] in
                        let popup = LZSnackAlertPopupView(
                            width: 320,
                            height: 522,
                            title: "영수증 검증 실패",
                            message: "\(purchaseError)",
                            buttonTitle: "닫기",
                            handler: { [weak self] in
                                
                            }
                        )
                        popup.show()
                    }
                }
            } else {
                let result = try await useCase.executeSubscriptionPurchase(paymentInfo: paymentInfo)
                switch result {
                case .success(let entity):
                    self.purchaseViewState = .success(entity)
                case .failure(let purchaseError):
                    self.purchaseViewState = .failure(purchaseError)
                }
            }
        }
    }
    
    func checkUnfinishedTransaction() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self = self else { return }
            guard let result = try await useCase.executeCheckUnfinishedTransaction() else { return }
            self.purchaseViewState = .success(result)
        }
    }
    
    
//    func purchaseSubscription(paymentInfo: PaymentInfoDTO) throws {
//        LZSnackConcurrencyManager.run { [weak self] in
//            guard let self = self else { return }
//            try await useCase.executeSubscriptionPurchase(paymentInfo: paymentInfo)
//        }
//    }
    
    
//    func fetchCoinProduct() {
//        LZSnackConcurrencyManager.run { [weak self] in
//            guard let self = self else { return }
//            self.coinProductList = try await useCase.executeFetchCoinProduct()
//        }
//    }
    
//    func fetchMembershipProduct() {
//        LZSnackConcurrencyManager.run { [weak self] in
//            guard let self = self else { return }
//            self.memberShipProductList = try await useCase.executeFetchMembershipProduct()
//        }
//    }
    
    func ensureProviderId(for menu: PaymentMenuType) async throws -> Int {
        if let cached = providerIdCache[menu] { return cached }
        let providers = try await paymentProvidersuseCase.fetchPaymentProviders(paymentMenuType: menu.rawValue)
        
        guard !providers.isEmpty else {
            throw NSError(domain: "IAP", code: -1, userInfo: [NSLocalizedDescriptionKey: "결제수단이 없습니다."])
        }
        
        
        if let iap = providers.first(where: { $0.paymentProviderMethod.uppercased() == "IOS_APP" }) {
            providerIdCache[menu] = iap.paymentProviderId
            return iap.paymentProviderId
        }
        
        //         서버가 이미 메뉴 타입으로 필터링해준다는 전제에서 첫 항목 fallback
        providerIdCache[menu] = providers[0].paymentProviderId
        return providers[0].paymentProviderId
    }
    
    // (편의) 코인/구독 헬퍼
    func ensureCoinProviderId() async throws -> Int { try await ensureProviderId(for: .coinProduct) }
    func ensureSubscriptionProviderId() async throws -> Int { try await ensureProviderId(for: .subscriptionProduct) }
    
    
    func loadCatalog() {
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
                
                self.coinItems = coins ?? []
                self.subscriptionItems = subs ?? []
                
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
    
    // 구매 시 VC에서 index로 요청하면 그대로 돌려주면 됨
    func coinItem(at index: Int) -> ProductItemEntity? {
        coinItems.indices.contains(index) ? coinItems[index] : nil
    }
    func subscriptionItem(at index: Int) -> ProductItemEntity? {
        subscriptionItems.indices.contains(index) ? subscriptionItems[index] : nil
    }
    
    
}
