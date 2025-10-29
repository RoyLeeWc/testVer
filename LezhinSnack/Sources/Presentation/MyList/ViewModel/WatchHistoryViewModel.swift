//
//  WatchHistoryViewModel.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/4/25.
//

import Combine

final class WatchHistoryViewModel {
    
    private let useCase: MyListUseCaseProtocol
    @Published var watchHistory: [WatchHistoryEntity]?
    
    init(useCase: MyListUseCaseProtocol) {
        self.useCase = useCase
    }
    
    
    func fetchWatchHistory() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            watchHistory = try await useCase.executeFetchWatchList()
        }
    }
    
    
    func deleteWatchHistory(with items: [WatchHistoryEntity]) {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            try await useCase.executeDeleteWatchList(items: items)
        }
    }
}
