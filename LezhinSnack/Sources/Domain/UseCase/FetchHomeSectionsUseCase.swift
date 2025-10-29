//
//  HomeUseCase.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/16/25.
//


protocol FetchHomeSectionsUseCaseProtocol {
    
//    func executeFetchSectionList() async throws -> [HomeSection]
//    func executeFetchSectionData(sectionType: HomeSectionType) async throws -> [HomeSectionEntity]
}


final class FetchHomeSectionsUseCase: FetchHomeSectionsUseCaseProtocol {
    
    private let repository: HomeSectionRepositoryProtocol
    
    init(homeSectionRepository: HomeSectionRepositoryProtocol) {
        self.repository = homeSectionRepository
    }
    
//    func executeFetchSectionList() async throws -> [HomeSection] {
//        return try await repository.fetchSectionList()
//    }
//    
//    func executeFetchSectionData(sectionType: HomeSectionType) async throws -> [HomeSectionEntity] {
//        
//        switch sectionType {
//        case .mainBanner:
//            return try await repository.fetchMainBannerData()
//        case .ranking:
//            return try await repository.fetchRankingData()
//        case .watchHistory:
//            return try await repository.fetchWatchHistoryData()
//        case .original:
//            return try await repository.fetchOriginalData()
//        case .curation:
//            return try await repository.fetchCurationData()
//        case .allContents:
//            return try await repository.fetchAllContentsData()
//        case .serialize:
//            return try await repository.fetchSerializeData()
//        }
//        
//    }
    
}
