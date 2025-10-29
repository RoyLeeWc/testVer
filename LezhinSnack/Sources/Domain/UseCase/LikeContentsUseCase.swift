//
//  LikeContentsUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 9/22/25.
//

import Foundation

 protocol LikeContentsUseCaseProtocol {
    func executeLikeContents(contentsId: String) async throws
}

final class LikeContentsUseCase: LikeContentsUseCaseProtocol {
    private let repository: ContentsRepositoryProtocol
    init(repository: ContentsRepositoryProtocol) { self.repository = repository }
    func executeLikeContents(contentsId: String) async throws {
        try await repository.like(contentsId: contentsId)
    }
}

