//
//  UnlikeContentsUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 9/22/25.
//

import Foundation

 protocol UnlikeContentsUseCaseProtocol {
    func executeUnlikeContents(contentsId: String) async throws
}

final class UnlikeContentsUseCase: UnlikeContentsUseCaseProtocol {
    private let repository: ContentsRepositoryProtocol
    init(repository: ContentsRepositoryProtocol) { self.repository = repository }
    func executeUnlikeContents(contentsId: String) async throws {
        try await repository.unlike(contentsId: contentsId)
    }
}
