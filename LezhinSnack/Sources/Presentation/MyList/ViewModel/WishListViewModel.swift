//
//  WishListViewModel.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/4/25.
//
import Combine

final class WishListViewModel {
    private let useCase: MyListUseCaseProtocol
    @Published var wishList: [WishListEntity]?
    
    init(useCase: MyListUseCaseProtocol) {
        self.useCase = useCase
    }
    
    
    func fetchWishList() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            wishList = try await useCase.executeFetchWishList()
        }
    }
    
    
    func deleteWishList(with items: [WishListEntity]) {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            try await useCase.executeDeleteWishList(items: items)
        }
    }
}
