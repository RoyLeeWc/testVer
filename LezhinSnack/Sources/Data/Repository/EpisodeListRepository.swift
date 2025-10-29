//
//  ContentListRepository.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/9/25.
//


protocol EpisodeListRepositoryProtocol {
    func fetchEpisodeList() async throws -> [EpisodeListEntity]
    func purchaseEpisode() async throws -> [EpisodeListEntity]
}


final class EpisodeListRepository: EpisodeListRepositoryProtocol {
    
    func fetchEpisodeList() async throws -> [EpisodeListEntity] {
        var episodes: [EpisodeListEntity] = []
        let totalCount = 50
        
        for index in 1...totalCount {
            let contentsID = ""              // 예시로 모두 같은 콘텐츠
            let episodeID = ""
            let episodeIndex = index
            let isEarlyAccess = index > totalCount - 10  // 마지막 10개만 얼리 액세스
            let isLocked = Bool.random()                // 랜덤 잠금 여부
            
            let entity = EpisodeListEntity(
                contentsID: contentsID,
                episodeID: episodeID,
                episodeIndex: episodeIndex,
                isLocked: isLocked,
                isEarlyAccess: isEarlyAccess,
                contentsAlias: "",
                episodeAlias: ""
                
            )
            episodes.append(entity)
        }
        
        let markedList = markFirstEarlyAccess(in: episodes)
        return markedList
    }
    
    func purchaseEpisode() async throws -> [EpisodeListEntity] {
        return []
    }
    
    
    /// 얼리액세스인 항목 중 가장 인덱스가 낮은 것에만 플래그를 추가
    func markFirstEarlyAccess(in episodes: [EpisodeListEntity]) -> [EpisodeListEntity] {
        // 1) 얼리액세스인 것 중 최소 episodeIndex 찾기
        guard let firstEAIndex = episodes
            .filter(\.isEarlyAccess)
            .min(by: { $0.episodeIndex < $1.episodeIndex })?
            .episodeIndex
        else {
            return episodes
        }
        
        // 2) 맵 돌면서 해당 인덱스만 true
        return episodes.map { ep in
            var copy = ep
            if ep.isEarlyAccess && ep.episodeIndex == firstEAIndex {
                copy.isFirstEarlyAccess = true
            }
            return copy
        }
    }
    
}
