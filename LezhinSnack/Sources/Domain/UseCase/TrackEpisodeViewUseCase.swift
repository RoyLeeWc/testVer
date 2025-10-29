//
//  TrackEpisodeViewUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 9/23/25.
//

import Foundation

protocol TrackEpisodeViewUseCaseProtocol {
    func executeTrackEpisodeView(contentsId: String,
                                 episodeId: String,
                                 subscriptionInfo: EpisodeViewCountAPIRequest.SubscriptionInfo?,
                                 isViewCountOnly: Bool?) async throws
}

final class TrackEpisodeViewUseCase: TrackEpisodeViewUseCaseProtocol {
    private let repository: ContentsRepositoryProtocol
    init(repository: ContentsRepositoryProtocol) { self.repository = repository }
    
    func executeTrackEpisodeView(contentsId: String,
                                 episodeId: String,
                                 subscriptionInfo: EpisodeViewCountAPIRequest.SubscriptionInfo?,
                                 isViewCountOnly: Bool?) async throws {
        try await repository.trackEpisodeView(contentsId: contentsId,
                                              episodeId: episodeId,
                                              subscriptionInfo: subscriptionInfo,
                                              isViewCountOnly: isViewCountOnly)
    }
}
