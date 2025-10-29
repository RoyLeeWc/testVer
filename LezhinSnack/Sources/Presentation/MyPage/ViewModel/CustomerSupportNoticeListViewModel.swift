//
//  CustomerSupportNoticeListViewModel.swift
//  LezhinSnack
//
//  Created by lwc on 10/20/25.
//

import Combine

final class CustomerSupportNoticeListViewModel {
    private let useCase: NoticesUseCaseProtocol
    private var subscriptions = Set<AnyCancellable>()

    @Published private(set) var items: [NoticeListEntity] = []
    @Published private(set) var noticeItems: NoticeEntity?
    @Published private(set) var errorMessage: String?

    init(useCase: NoticesUseCaseProtocol) {
        self.useCase = useCase
    }

    func fetchNoticeList() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            let list = try await self.useCase.fetchNoticeList()   // [NoticeListEntity]
            self.items = list
        } onError: { [weak self] error in
            self?.errorMessage = "공지사항 목록을 불러오지 못했어요. 잠시 후 다시 시도해 주세요."
        }
    }
    
    func fetchNotice(noiceId: String) {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            let item = try await self.useCase.fetchNotice(noiceId: noiceId)
            self.noticeItems = item
        } onError: { [weak self] error in
            self?.errorMessage = "공지사항 목록을 불러오지 못했어요. 잠시 후 다시 시도해 주세요."
        }
    }
    
}
