//
//  CustomerSupportFAQDetailViewModel.swift
//  LezhinSnack
//
//  Created by lwc on 10/21/25.
//

// FaqDetailViewModel.swift
import Combine

final class CustomerSupportFAQDetailViewModel {
    private let useCase: FAQUseCaseProtocol
    private let faqId: Int

    @Published private(set) var item: FaqDetailEntity?
    @Published private(set) var errorMessage: String?

    init(useCase: FAQUseCaseProtocol, faqId: Int) {
        self.useCase = useCase
        self.faqId = faqId
    }

    func fetch() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            let entity = try await self.useCase.fetchFaqDetail(faqId: self.faqId)
            self.item = entity
        } onError: { [weak self] _ in
            self?.errorMessage = "FAQ를 불러오지 못했어요. 잠시 후 다시 시도해 주세요."
        }
    }
}
