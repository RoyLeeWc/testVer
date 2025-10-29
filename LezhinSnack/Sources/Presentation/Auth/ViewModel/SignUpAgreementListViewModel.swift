//
//  SignUpAgreementListViewModel.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/18/25.
//

import Foundation


final class SignUpAgreementListViewModel {
    
    deinit {
        printX("메모리 해제")
    }
    
    @Published var agreementList: [AgreementEntity]?
    
    private let authUseCase: AuthUseCaseProtocol
    
    init(authUseCase: AuthUseCaseProtocol) {
        self.authUseCase = authUseCase
    }
    
    func fetchAgreementList() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            agreementList = try await authUseCase.executeFetchAgreementList()
        }
    }
    
    func welcomefetchAgreementList() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            agreementList = try await authUseCase.executeWelcomeFetchAgreementList()
        }
    }
    
}
