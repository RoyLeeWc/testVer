//
//  EpisodeListViewModel.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/9/25.
//

import Combine

final class EpisodeListViewModel {
    
    private let useCase: EpisodeListUseCaseProtocol
    
    private let episodeDetailsCase: FetchEpisodeMetaUseCaseProtocol
    
    @Published var episodeList: [EpisodeListEntity]?
    
    @Published var episodeDetailList: DisplayEpisodeEntity?
    
    init(episodeListUseCase: EpisodeListUseCaseProtocol,
         episodeDetailsCase: FetchEpisodeMetaUseCaseProtocol) {
        self.useCase = episodeListUseCase
        self.episodeDetailsCase = episodeDetailsCase
    }
    
    func fetchEpisodeDetails(contentsAlias: String, episodeAlias: String) {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            episodeDetailList = try await episodeDetailsCase.executeFetchEpisodeMeta(contentsAlias: contentsAlias, episodeAlias: episodeAlias)
        }
    }

    func fetchEpisodes() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            episodeList = try await useCase.executeFetchEpisodeList()
        }
    }
   
}
