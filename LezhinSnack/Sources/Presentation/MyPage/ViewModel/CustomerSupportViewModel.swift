//
//  CustomerSupportViewModel.swift
//  LezhinSnack
//
//  Created by lwc on 10/20/25.
//

import Combine

final class CustomerSupportViewModel {
    private let useCase: FAQUseCaseProtocol
    private var subscriptions = Set<AnyCancellable>()

    
    @Published private(set) var items: [FaqCategoryEntity] = []  // 카테고리
    @Published private(set) var faqs:  [FaqEntity] = []          // FAQ 전체
    @Published private(set) var errorMessage: String?

    init(useCase: FAQUseCaseProtocol) {
        self.useCase = useCase
    }

    /// FAQ 초기 데이터(카테고리 + FAQ 전체) 동시 로드
    func fetchFAQStartup() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            async let cats = self.useCase.fetchFaqCategories()
            async let all  = self.useCase.fetchFaqList()
            let (item, faq) = try await (cats, all)
            self.items = item
            self.faqs  = faq
        } onError: { [weak self] _ in
            self?.errorMessage = "FAQ 정보를 불러오지 못했어요. 잠시 후 다시 시도해 주세요."
        }
    }
}
