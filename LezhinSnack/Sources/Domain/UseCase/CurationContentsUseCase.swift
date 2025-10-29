//
//  CurationContentsUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 9/11/25.
//

protocol CurationContentsUseCaseProtocol {
    func executeFetchContentsCuration(curationId: String) async throws -> [ContentsCurationItemDTO]
}

final class CurationContentsUseCase: CurationContentsUseCaseProtocol {
    private let repository: CurationRepositoryProtocol
    init(curationRepository: CurationRepositoryProtocol) { self.repository = curationRepository }

    func executeFetchContentsCuration(curationId: String) async throws -> [ContentsCurationItemDTO] {
        try await repository.fetchContentsCuration(curationId: curationId)
    }
}
