//
//  MySubscriptionUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 10/1/25.
//

protocol MySubscriptionUseCaseProtocol {
    func executeFetchMySubscription() async throws -> MySubscriptionInfoEntity?
}

final class MySubscriptionUseCase: MySubscriptionUseCaseProtocol {
    private let repository: SubscriptionRepositoryProtocol
    init(repository: SubscriptionRepositoryProtocol) { self.repository = repository }
    
    func executeFetchMySubscription() async throws -> MySubscriptionInfoEntity? {
        try await repository.fetchMySubscription()
    }
}
