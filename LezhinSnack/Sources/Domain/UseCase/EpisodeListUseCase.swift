//
//  ContentListUseCase.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/9/25.
//


protocol EpisodeListUseCaseProtocol {
    
    func executeFetchEpisodeList() async throws -> [EpisodeListEntity]
    
    func executePurchaseEpisode() async throws -> [EpisodeListEntity]
    
}


final class EpisodeListUseCase: EpisodeListUseCaseProtocol {
    
    let repository: EpisodeListRepositoryProtocol
    
    init(episodeListRepository: EpisodeListRepositoryProtocol) {
        self.repository = episodeListRepository
    }
    
    func executeFetchEpisodeList() async throws -> [EpisodeListEntity] {
        try await repository.fetchEpisodeList()
    }
    
    func executePurchaseEpisode() async throws -> [EpisodeListEntity] {
        try await repository.purchaseEpisode()
    }
    
}
