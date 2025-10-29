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


    @Published var coinUsage: [CoinUsageEntity] = []
    @Published var coinCharges: [CoinChargeEntity] = []
    @Published var userCoin: UserCoinEntity?
    
    // 필터 상태(충전내역용)
    private(set) var currentFilter: CoinChargeFilter = .ALL

    
    var subscriptions = Set<AnyCancellable>()
    
//    private let historyUseCase: HistoryUseCaseProtocol
    
    private let userUseCase: UserUseCaseProtocol
    private let fetchCoinCharges: CoinChargesUseCaseProtocol
    private let fetchCoinUsage: CoinUsageHistoryUseCaseProtocol
    
    
    // 공용 페이지네이터 2개
    private lazy var chargesPager = Paginator<CoinChargeEntity>(size: 20) { [weak self]
        (page: Int, size: Int) async throws -> PagedEntity<CoinChargeEntity> in
        guard let self else { throw CancellationError() }
        return try await self.fetchCoinCharges.executeFetchCoinCharges(page: page, size: size, filter: self.currentFilter)
    }
    
    private lazy var usagePager = Paginator<CoinUsageEntity>(size: 20) { [weak self]
        (page: Int, size: Int) async throws -> PagedEntity<CoinUsageEntity> in
        guard let self else { throw CancellationError() }
        return try await self.fetchCoinUsage.executeFetchCoinUsage(page: page, size: size)
    }
    
    init(userUseCase: UserUseCaseProtocol,
         fetchCoinCharges: CoinChargesUseCaseProtocol,
         fetchCoinUsage: CoinUsageHistoryUseCaseProtocol) {
        self.userUseCase = userUseCase
        self.fetchCoinCharges = fetchCoinCharges
        self.fetchCoinUsage = fetchCoinUsage
    }
    
    // MARK: - 충전 내역
    func fetchCoinChargeHistory() {
        // 페이지네이터가 로딩/마지막 가드 처리
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            let items = try await self.chargesPager.loadNext()
            self.coinCharges = items
        }
    }
    
    func reloadCoinCharges(filter: CoinChargeFilter? = nil) {
        if let f = filter { currentFilter = f }
        chargesPager.reset()
        fetchUserCoin()
        fetchCoinChargeHistory()
    }
    
    func fetchNextCoinChargesIfNeeded(visibleIndex: Int) {
        // 끝에서 5개 이내 진입 시 다음 페이지 시도
        let threshold = max(0, coinCharges.count - 5)
        if visibleIndex >= threshold {
            fetchCoinChargeHistory()
        }
    }
    
    // MARK: - 사용 내역
    func fetchCoinUsageHistory() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            let items = try await self.usagePager.loadNext()
            self.coinUsage = items
        }
    }
    
    func reloadCoinUsage() {
        usagePager.reset()
        fetchCoinUsageHistory()
    }
    
    func fetchNextCoinUsageIfNeeded(visibleIndex: Int) {
        let threshold = max(0, coinUsage.count - 5)
        if visibleIndex >= threshold {
            fetchCoinUsageHistory()
        }
    }
    
    // MARK: - 헤더용 잔액
    func fetchUserCoin() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            self.userCoin = try await self.userUseCase.executeFetchUserCoin()
        }
    }
}
