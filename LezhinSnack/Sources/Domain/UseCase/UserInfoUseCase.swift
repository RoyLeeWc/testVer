//
//  UserInfoUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 9/30/25.
//

protocol UserInfoUseCaseProtocol {
    func fetchUserInfo() async throws -> UserInfoEntity
}

final class UserInfoUseCase: UserInfoUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    init(repository: UserRepositoryProtocol) { self.repository = repository }
    
    func fetchUserInfo() async throws -> UserInfoEntity {
        try await repository.fetchUserInfo()
    }
}
