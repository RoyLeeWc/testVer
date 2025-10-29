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
    
    @Published var coinProductList: [CoinProductEntity]?
    @Published var memberShipProductList: [MembershipProductEntity]?
    @Published var footerTextList: [ShopFooterEntity]?
    @Published var purchaseViewState: PurchaseViewState = .idle
    
    init(inAppPurchaseUseCase: InAppPurchaseUseCaseProtocol) {
        self.useCase = inAppPurchaseUseCase
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
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self = self else { return }
            self.purchaseViewState = .loading
            let result = try await useCase.executePurchase(paymentInfo: paymentInfo)
            switch result {
            case .success(let entity):
                self.purchaseViewState = .success(entity)
            case .failure(let purchaseError):
                self.purchaseViewState = .failure(purchaseError)
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
    
    
    func purchaseSubscription(paymentInfo: PaymentInfoDTO) throws {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self = self else { return }
            try await useCase.executeSubscriptionPurchase(paymentInfo: paymentInfo)
        }
    }
    
    
    func fetchCoinProduct() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self = self else { return }
            self.coinProductList = try await useCase.executeFetchCoinProduct()
        }
    }
    
    func fetchMembershipProduct() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self = self else { return }
            self.memberShipProductList = try await useCase.executeFetchMembershipProduct()
        }
    }
    
    
}
