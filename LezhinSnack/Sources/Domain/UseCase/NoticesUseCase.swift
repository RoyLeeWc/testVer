//
//  NoticesUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 10/17/25.


protocol NoticesUseCaseProtocol {
    func fetchNotice(noiceId: String) async throws -> NoticeEntity?
    func fetchNoticeList() async throws -> [NoticeListEntity]
}

final class NoticesUseCase: NoticesUseCaseProtocol {
    private let repository: CustomerSupportRepositoryProtocol
    init(repository: CustomerSupportRepositoryProtocol) { self.repository = repository }

    func fetchNotice(noiceId: String) async throws -> NoticeEntity? {
        try await repository.fetchNotice(id: noiceId)
    }
    
    func fetchNoticeList() async throws -> [NoticeListEntity] {
        try await repository.fetchNoticeList()
    }
    
}
