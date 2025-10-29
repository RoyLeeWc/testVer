//
//  CurationUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 9/10/25.
//

protocol CurationUseCaseProtocol {
    func executeFetchCurationList() async throws -> [CurationItemDTO]
}

final class CurationUseCase: CurationUseCaseProtocol {
    private let repository: CurationRepositoryProtocol
    init(curationRepository: CurationRepositoryProtocol) {
        self.repository = curationRepository
    }

    func executeFetchCurationList() async throws -> [CurationItemDTO] {
        try await repository.fetchCurationList()
    }
}
