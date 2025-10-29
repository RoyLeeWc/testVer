//
//  DisplayVideoUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 9/18/25.
//

protocol DisplayVideoUseCaseProtocol {
    func executeFetchDisplayVideo(episodeId: String,
                 drmType: DRMType,
                 drmLicenseUserId: String) async throws -> DisplayVideoEntity
}

final class DisplayVideoUseCase: DisplayVideoUseCaseProtocol {
    private let repository: ContentsRepositoryProtocol
    init(repository: ContentsRepositoryProtocol) { self.repository = repository }

    func executeFetchDisplayVideo(episodeId: String,
                 drmType: DRMType,
                 drmLicenseUserId: String) async throws -> DisplayVideoEntity {
        try await repository.fetchDisplayVideo(
            episodeId: episodeId,
            drmType: drmType.rawValue,
            drmLicenseUserId: drmLicenseUserId
        )
    }
}
