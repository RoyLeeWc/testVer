//
//  WithdrawalReasonsUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 9/30/25.
//

protocol WithdrawalReasonsUseCaseProtocol {
    func fetchWithdrawalReasons() async throws -> [WithdrawalReasonEntity]
}


final class WithdrawalReasonsUseCase: WithdrawalReasonsUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    init(repository: UserRepositoryProtocol) { self.repository = repository }
    
    func fetchWithdrawalReasons() async throws -> [WithdrawalReasonEntity] {
        try await repository.fetchWithdrawalReasons()
    }
}


