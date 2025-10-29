//
//  ContentsBannerUseCase.swift
//  LezhinSnack
//
//  Created by lwc on 9/11/25.
//

import Foundation

protocol BannerUseCaseProtocol {
    func executeFetchContentsBanners(curationId: String) async throws -> [ContentsBannerItemDTO]
}

final class BannerUseCase: BannerUseCaseProtocol {
    private let repository: CurationRepositoryProtocol
    init(bannerrepository: CurationRepositoryProtocol) {
        self.repository = bannerrepository
    }
    
    func executeFetchContentsBanners(curationId: String) async throws -> [ContentsBannerItemDTO] {
        try await repository.fetchContentsBanners(curationId: curationId)
    }
}
