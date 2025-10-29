//
//  PaymentHistoryViewModel.swift
//  LezhinSnack
//
//  Created by lwc on 10/10/25.
//

import Combine

final class PaymentHistoryViewModel {

    // 리스트 바인딩용
    @Published var payments: [PaymentHistoryEntity] = []
    // 상세 팝업/화면 연동용
    @Published var paymentDetail: PaymentDetailEntity?

    private let historyUseCase: PaymentHistoryUseCaseProtocol
    private let detailUseCase: PaymentDetailUseCaseProtocol
    
    // 공용 페이지네이터
    private lazy var pager = Paginator<PaymentHistoryEntity>(size: 20) { [weak self] (page, size) in
        guard let self else { throw CancellationError() }
        return try await self.historyUseCase.executeFetchUserPayments(page: page, size: size)
    }

    init(
        historyUseCase: PaymentHistoryUseCaseProtocol,
        detailUseCase: PaymentDetailUseCaseProtocol
    ) {
        self.historyUseCase = historyUseCase
        self.detailUseCase = detailUseCase
    }

    // 최초/새로고침
    func reload() {
        pager.reset()
        loadNext()
    }

    // 다음 페이지
    func loadNext() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            let items = try await self.pager.loadNext()
            self.payments = items
        }
    }

    // 화면 끝 근처에서 다음 페이지 시도
    func loadNextIfNeeded(visibleIndex: Int) {
        let threshold = max(0, payments.count - 5)
        if visibleIndex >= threshold { loadNext() }
    }

    // 셀 탭 시 상세 호출
    func fetchPaymentDetail(tradeId: String) {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            self.paymentDetail = try await self.detailUseCase.executeFetchPaymentDetail(transactionId: tradeId)
        }
    }
}
