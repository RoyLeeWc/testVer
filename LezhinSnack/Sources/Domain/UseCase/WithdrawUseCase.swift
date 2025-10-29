//
//  WithdrawUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 9/30/25.
//

protocol WithdrawUseCaseProtocol {
    func withdraw(categoryId: Int, reason: String) async throws -> UserWithdrawalResultEntity
}

final class WithdrawUseCase: WithdrawUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    init(repository: UserRepositoryProtocol) { self.repository = repository }
    
    public func withdraw(categoryId: Int, reason: String) async throws -> UserWithdrawalResultEntity {
        try await repository.withdraw(categoryId: categoryId, reason: reason)
    }
}
