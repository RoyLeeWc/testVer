//
//  UnfavoriteContentsUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 9/23/25.
//
import Foundation


protocol UnfavoriteContentsUseCaseProtocol {
    func executeUnfavoriteContents(contentsId: String) async throws
}

final class UnfavoriteContentsUseCase: UnfavoriteContentsUseCaseProtocol {
    private let repository: ContentsRepositoryProtocol
    init(repository: ContentsRepositoryProtocol) { self.repository = repository }

    func executeUnfavoriteContents(contentsId: String) async throws {
        try await repository.unfavorite(contentsId: contentsId)
    }
}
