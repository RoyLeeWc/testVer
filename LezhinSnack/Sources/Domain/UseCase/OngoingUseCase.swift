//
//  OngoingUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 9/11/25.
//

protocol OngoingUseCaseProtocol {
    func executeFetchContentsOngoing() async throws -> [ContentsOngoingItemDTO]
}

final class OngoingUseCase: OngoingUseCaseProtocol {
    private let repository: CurationRepositoryProtocol
    init(ongoingRepository: CurationRepositoryProtocol) { self.repository = ongoingRepository }

    func executeFetchContentsOngoing() async throws -> [ContentsOngoingItemDTO] {
        try await repository.fetchContentsOngoing()
    }
}
