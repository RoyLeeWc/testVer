//
//  HomeViewerPrefetchInteractor.swift
//  LezhinSnack
//
//  Created by lwc on 9/19/25.
//

import Foundation

final class HomeViewerPrefetchInteractor {
  private let fetchContentsDetailCases: FetchContentsDetailUseCaseProtocol
  private let fetchContentsEpisodesCases: FetchContentsEpisodesUseCaseProtocol

  init(contentsDetailUseCases: FetchContentsDetailUseCaseProtocol,
       contentsEpisodesCases: FetchContentsEpisodesUseCaseProtocol) {
    self.fetchContentsDetailCases = contentsDetailUseCases
    self.fetchContentsEpisodesCases = contentsEpisodesCases
  }

  func prepare(contentsAlias: String, preferEpisodeAlias: String?) async throws -> ViewerInput {
    let detail = try await fetchContentsDetailCases.executeFetchContentsDetail(alias: contentsAlias)
    let episodes = try await fetchContentsEpisodesCases.executeFetchContentsEpisodes(contentsId: detail.id)
    let initial = preferEpisodeAlias ?? detail.firstEpisodeAlias ?? "1"
    return ViewerInput(contentsAlias: contentsAlias,
                       initialEpisodeAlias: initial,
                       detail: detail,
                       episodes: episodes)
  }
}
