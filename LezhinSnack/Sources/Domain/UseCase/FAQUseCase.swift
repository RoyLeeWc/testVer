//
//  FAQUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 10/20/25.
//

// FaqsUseCase.swift

protocol FAQUseCaseProtocol {
    func fetchFaqCategories() async throws -> [FaqCategoryEntity]
    func fetchFaqList() async throws -> [FaqEntity]
    func fetchFaqDetail(faqId: Int) async throws -> FaqDetailEntity?
}

final class FAQUseCase: FAQUseCaseProtocol {
    private let repository: CustomerSupportRepositoryProtocol
    init(repository: CustomerSupportRepositoryProtocol) { self.repository = repository }

    func fetchFaqCategories() async throws -> [FaqCategoryEntity] {
        try await repository.fetchFaqCategories()
    }

    func fetchFaqList() async throws -> [FaqEntity] {
        try await repository.fetchFaqList()
    }

    func fetchFaqDetail(faqId: Int) async throws -> FaqDetailEntity? {
        try await repository.fetchFaqDetail(faqId: faqId)
    }
}
