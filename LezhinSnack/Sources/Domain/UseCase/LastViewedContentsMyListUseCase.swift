//
//  LastViewedContentsMyListUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 10/13/25.
//


protocol LastViewedMyListUseCaseProtocol {
    func executeLastViewedContentsMyList(size: Int, page: Int, sort: ContentsListSort, isPaged: Bool?) async throws -> LastViewedContentsPageEntity
}

final class LastViewedMyListUseCase: LastViewedMyListUseCaseProtocol {
    private let repository: MyListRepositoryProtocol
    init(repository: MyListRepositoryProtocol) { self.repository = repository }

    func executeLastViewedContentsMyList(size: Int, page: Int, sort: ContentsListSort, isPaged: Bool?) async throws -> LastViewedContentsPageEntity {
        try await repository.fetchLastViewedContents(size: size, page: page, sort: sort, isPaged: isPaged)
    }
}
