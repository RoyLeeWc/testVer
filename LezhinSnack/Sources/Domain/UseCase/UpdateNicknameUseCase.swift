//
//  UpdateNicknameUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 9/30/25.
//

protocol UpdateNicknameUseCaseProtocol {
    func updateNickname(_ nickname: String) async throws -> UpdateNicknameEntity
}

final class UpdateNicknameUseCase: UpdateNicknameUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    init(repository: UserRepositoryProtocol) { self.repository = repository }
    
    public func updateNickname(_ nickname: String) async throws -> UpdateNicknameEntity {
        try await repository.updateNickname(nickname)
    }
}
