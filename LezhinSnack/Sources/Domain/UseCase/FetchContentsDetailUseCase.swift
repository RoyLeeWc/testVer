//
//  FetchContentsDetailUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 9/18/25.
//

protocol FetchContentsDetailUseCaseProtocol {
    func executeFetchContentsDetail(alias: String) async throws -> DisplayContentsDetailEntity
}

final class FetchContentsDetailUseCase: FetchContentsDetailUseCaseProtocol {
    private let repo: ContentsRepositoryProtocol
    init(repo: ContentsRepositoryProtocol) { self.repo = repo }
    
    func executeFetchContentsDetail(alias: String) async throws -> DisplayContentsDetailEntity {
        try await repo.fetchContentsDetail(alias: alias)
    }
}
