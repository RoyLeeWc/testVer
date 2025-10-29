//
//  FavoriteContentsUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 9/23/25.
//

import Foundation

 protocol FavoriteContentsUseCaseProtocol {
    func executeFavoriteContents(contentsId: String, episodeId: String) async throws
}

final class FavoriteContentsUseCase: FavoriteContentsUseCaseProtocol {
    private let repository: ContentsRepositoryProtocol
    init(repository: ContentsRepositoryProtocol) { self.repository = repository }

    func executeFavoriteContents(contentsId: String, episodeId: String) async throws {
        try await repository.favorite(contentsId: contentsId, episodeId: episodeId)
    }
}
