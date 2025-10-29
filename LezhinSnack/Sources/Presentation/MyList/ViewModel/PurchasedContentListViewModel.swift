//
//  PurchasedContentListViewModel.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/4/25.
//

import Combine

final class PurchasedContentListViewModel {
    private let useCase: MyListUseCaseProtocol
    
    @Published var purchasedContentList: [PurchasedContentEntity]?
    
    init(useCase: MyListUseCaseProtocol) {
        self.useCase = useCase
    }
    
    
    func fetchPurchasedContentList() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            purchasedContentList = try await useCase.executeFetchPurchasedList()
        }
    }
    
    
    func deletePurchasedContentList(with items: [PurchasedContentEntity]) {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            try await useCase.executeDeletePurchasedList(items: items)
        }
    }
}
