//
//  EpisodeListViewModel.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/9/25.
//

import Combine

final class EpisodeListViewModel {
    
    private let useCase: EpisodeListUseCaseProtocol
    
    
    @Published var episodeList: [EpisodeListEntity]?
    
    init(episodeListUseCase: EpisodeListUseCaseProtocol) {
        self.useCase = episodeListUseCase
    }
    
    
    
    func fetchEpisodes() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            episodeList = try await useCase.executeFetchEpisodeList()
        }
    }
    
    
    
    
}
