//
//  MyWalletViewModel.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/12/25.
//

import AuthenticationServices
import SwiftyUserDefaults
import Combine
import Alamofire


final class ChargeHistoryViewModel {
    
    
    deinit {
        printX("메모리 해제")
    }
    
    
    @Published var purchaseHistory: [PurchaseHistoryEntity]?
    @Published var coinChargeHistory: [CoinChargeHistoryEntity]?
    @Published var userCoinEntity: UserCoinEntity?
    
    var subscriptions = Set<AnyCancellable>()
    
    private let historyUseCase: HistoryUseCaseProtocol
    private let userUseCase: UserUseCaseProtocol
    
    init(historyUserCase: HistoryUseCaseProtocol,
         userUseCase: UserUseCaseProtocol) {
        self.historyUseCase = historyUserCase
        self.userUseCase = userUseCase
    }
    
    
    func fetchUserCoinBalance() {
        LZSnackConcurrencyManager.run {
            self.userCoinEntity = try await self.userUseCase.executeFetchUserCoinBalance()
        }
    }
    
    
    func fetchPurchaseHistory() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            self.purchaseHistory = try await historyUseCase.executePurchaseHistory()
        }
    }
    
    
    func fetchCoinChargeHistory() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            self.coinChargeHistory = try await historyUseCase.executeCoinChargeHistory()
        }
    }
    
    
    func fetchUserCoinWithCoinChargeHistory() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            self.coinChargeHistory = try await historyUseCase.executeCoinChargeHistory()
            self.userCoinEntity = try await self.userUseCase.executeFetchUserCoinBalance()
        }
    }
    
    
    
}
