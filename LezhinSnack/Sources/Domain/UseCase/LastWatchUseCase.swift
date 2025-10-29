//
//  LastWatchUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 9/11/25.
//

protocol LastWatchUseCaseProtocol {
    func executeFetchContentsLastWatch() async throws -> [ContentsLastWatcItemDTO]
}

final class LastWatchUseCase: LastWatchUseCaseProtocol {
    private let repository: CurationRepositoryProtocol
    init(lastWatchRepository: CurationRepositoryProtocol) { self.repository = lastWatchRepository }

    func executeFetchContentsLastWatch() async throws -> [ContentsLastWatcItemDTO] {
        try await repository.fetchContentsLastWatch()
    }
}
