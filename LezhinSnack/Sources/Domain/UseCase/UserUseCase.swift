//
//  UserUseCase.swift
//  LezhinSnack
//
//  Created by 신진우 on 6/3/25.
//

protocol UserUseCaseProtocol {
    func executeFetchUserCoinBalance() async throws -> UserCoinEntity
    func executeUpdateUserNickname() async throws
}


struct UserUseCase: UserUseCaseProtocol {
    
    private let repository: UserRepositoryProtocol
    
    init(userRepositoryProtocol: UserRepositoryProtocol) {
        self.repository = userRepositoryProtocol
    }
    
    func executeFetchUserCoinBalance() async throws -> UserCoinEntity {
        return try await repository.fetchUserCoinBalance()
    }
    
    func executeUpdateUserNickname() async throws {
        
    }
    
}
