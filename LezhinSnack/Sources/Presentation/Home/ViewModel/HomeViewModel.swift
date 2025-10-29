//
//  HomeViewModel.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/16/25.
//

import Alamofire
import Foundation
import Combine
import UIKit



// MARK: - 모델 및 섹션 타입 정의
enum HomeSectionType: String, CaseIterable {
    case mainBanner
    case ranking
    case watchHistory
    case original
    case curation
    case allContents
    case serialize
}

struct HomeSection: Hashable {
   let id = UUID()
   let type: HomeSectionType
   let headerTitle: String?
}

final class HomeViewModel {
    
    private let useCase: FetchHomeSectionsUseCaseProtocol
    
    init(fetchHomeSectionsUseCase: FetchHomeSectionsUseCaseProtocol) {
        self.useCase = fetchHomeSectionsUseCase
    }
    
    @Published var sections: [HomeSection]?
    @Published var sectionsData: (section: HomeSection, homeSectionEntityArray: [HomeSectionEntity])?
    
    
    func fetchSectionList() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            sections = try await useCase.executeFetchSectionList()
        }
    }
    
    func fetchSectionsData(sections: [HomeSection]) {
        for section in sections {
            LZSnackConcurrencyManager.run { [weak self] in
                guard let self else { return }
                let homeSectionEntity = try await useCase.executeFetchSectionData(sectionType: section.type)
                sectionsData = (section: section, homeSectionEntityArray: homeSectionEntity)
            }
        }
    }
    
    
    func getPlaceholderItems(for section: HomeSection) -> [HomeSectionEntity] {
        switch section.type {
        case .mainBanner:
            return (0..<5).map { index in
                var item = HomeSectionEntity(title: "Banner \(index + 1)", color: .black)
                item.isPlaceholder = true
                return item
            }
            
        case .ranking:
            return (0..<12).map { idx in
                var item = HomeSectionEntity(title: "Ranking \(idx + 1)")
                item.isPlaceholder = true
                return item
            }
            
        case .watchHistory:
            return (0..<10).map { idx in
                var item = HomeSectionEntity(title: "Watch \(idx)")
                item.isPlaceholder = true
                return item
            }
            
        case .original:
            return (0..<5).map { index in
                var item = HomeSectionEntity(title: "Original \(index + 1)", color: .black)
                item.isPlaceholder = true
                return item
            }
            
        case .curation:
            return (0..<10).map { idx in
                var item = HomeSectionEntity(title: "Item \(idx)")
                item.isPlaceholder = true
                return item
            }
            
        case .allContents:
            return (0..<10).map { idx in
                var item = HomeSectionEntity(title: "Vertical Item \(idx)")
                item.isPlaceholder = true
                return item
            }
        case .serialize:
            return (0..<10).map { idx in
                var item = HomeSectionEntity(title: "Vertical Item \(idx)")
                item.isPlaceholder = true
                return item
            }
        }
    }
    
    
    
}
