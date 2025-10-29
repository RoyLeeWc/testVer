//
//  UserUseCase.swift
//  LezhinSnack
//
//  Created by 신진우 on 6/3/25.
//

protocol UserUseCaseProtocol {
    func executeFetchUserCoin() async throws -> UserCoinEntity
}


struct UserUseCase: UserUseCaseProtocol {
    
    private let repository: UserRepositoryProtocol
    
    init(userRepositoryProtocol: UserRepositoryProtocol) {
        self.repository = userRepositoryProtocol
    }
    
    func executeFetchUserCoin() async throws -> UserCoinEntity {
        return try await repository.fetchUserCoin()
    }
    
}
