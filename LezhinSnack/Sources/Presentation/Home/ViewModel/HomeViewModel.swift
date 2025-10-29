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
   let id: String
   let type: HomeSectionType
   let headerTitle: String?
    
    static func == (lhs: HomeSection, rhs: HomeSection) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
enum EmptyViewModelError: Error { case emptyViewModel }

final class HomeViewModel {
    

    
    private let curationUseCase: CurationUseCaseProtocol
    private let rankingUseCase: RankingUseCaseProtocol
    private let bannerUseCase: BannerUseCaseProtocol
    private let ongoingUseCase: OngoingUseCaseProtocol
    private let lastWatchUseCase: LastWatchUseCaseProtocol
    private let curationContentsUseCase: CurationContentsUseCaseProtocol
    
    init(curationUseCase: CurationUseCaseProtocol,
         rankingUseCase: RankingUseCaseProtocol,
         bannerUseCase: BannerUseCaseProtocol,
         ongoingUseCase: OngoingUseCaseProtocol,
         lastWatchUseCase: LastWatchUseCaseProtocol,
         curationContentsUseCase: CurationContentsUseCaseProtocol) {
        self.curationUseCase = curationUseCase
        self.rankingUseCase =  rankingUseCase
        self.bannerUseCase = bannerUseCase
        self.ongoingUseCase = ongoingUseCase
        self.lastWatchUseCase = lastWatchUseCase
        self.curationContentsUseCase = curationContentsUseCase
    }
    
    @Published var sections: [HomeSection]?
    @Published var sectionsData: (section: HomeSection, homeSectionEntityArray: [HomeSectionEntity])?

    //  섹션별 어떤 데이터가 실려있는지 식별용
    public enum SectionPayloadKind { case banner, ranking, ongoing, lastWatch, curation }
    //  섹션 인덱스 → 페이로드 종류
    public var payloadKindBySectionId: [String: SectionPayloadKind] = [:]
    //  배너 엔티티 저장 (섹션 인덱스 → 엔티티 배열)
    @Published var bannerEntitiesBySectionId: [String: [ContentsBannerItemEntity]] = [:]
    @Published var rankingEntitiesBySectionId: [String: [ContentsRankingItemEntity]] = [:]
    @Published var ongoingEntitiesBySectionId: [String: [ContentsOngoingItemEntity]]     = [:]
    @Published var lastWatchEntitiesBySectionId: [String: [ContentsLastWatchItemEntity]]  = [:]
    @Published var curationEntitiesBySectionId: [String: [ContentsCurationItemEntity]]   = [:]
    
    //  Coordinator가 구독할 이벤트
    let playRequested = PassthroughSubject<PlayInput, Never>()
    
    private var fetchVersion: Int = 0
    private var inflight: Int = 0
    var onAllSectionsLoaded: (() -> Void)?
    
    private func finishOne(_ version: Int) {
        // 이전 실행(run)의 콜백이면 무시
        guard version == fetchVersion else { return }
        inflight -= 1
        if inflight == 0 {
            onAllSectionsLoaded?()
            // 필요하면 노티도 발행
            NotificationCenter.default.post(name: .LZSHomeAllSectionsLoaded, object: nil)
        }
    }
    
    /// VC가 섹션과 인덱스를 넘겨주면, VM이 어떤 컨텐츠인지 해석
    func didSelect(section: HomeSection, index: Int) {
        guard let input = makePlayInput(section: section, index: index) else { return }
        playRequested.send(input)
    }
    
    private func makePlayInput(section: HomeSection, index: Int) -> PlayInput? {
        let secId = section.id
        let payload = payloadKindBySectionId[secId]
        
        switch section.type {
            
        case .mainBanner:
            if payload == .ongoing,
               let arr = ongoingEntitiesBySectionId[secId], index < arr.count {
                let it = arr[index]
                return PlayInput(contentsAlias: it.contentsAlias, episodeAlias: it.episodeAlias)
            } else if payload == .ranking,
                      let arr = rankingEntitiesBySectionId[secId], index < arr.count {
                let it = arr[index]
                return PlayInput(contentsAlias: it.contentsAlias)
            } else if payload == .banner,
                      let arr = bannerEntitiesBySectionId[secId], index < arr.count {
                let it = arr[index]
                let alias = it.targetContentsAlias ?? it.contentsAlias ?? ""
                guard !alias.isEmpty else { return nil }
                return PlayInput(contentsAlias: alias, episodeAlias: it.targetEpisodeAlias)
            }
            return nil
            
        case .ranking:
            if  payload == .ranking,
                let arr = rankingEntitiesBySectionId[secId], index < arr.count {
                let it = arr[index]
                return PlayInput(contentsAlias: it.contentsAlias)
            } else if payload == .curation,
                      let arr = curationEntitiesBySectionId[secId], index < arr.count {
                let it = arr[index]
                return PlayInput(contentsAlias: it.contentsAlias)
            }
            
            return nil
            
        case .watchHistory:
            if let arr = lastWatchEntitiesBySectionId[secId], index < arr.count {
                let it = arr[index]
                let ep = it.currentEpisode ?? 1
                return PlayInput(contentsAlias: it.contentsAlias, episodeAlias: String(ep))
            }
            return nil
            
        case .original:
            if payload == .ongoing,
               let arr = ongoingEntitiesBySectionId[secId], index < arr.count {
                let it = arr[index]
                return PlayInput(contentsAlias: it.contentsAlias, episodeAlias: it.episodeAlias)
            } else if payload == .curation,
                     let arr = curationEntitiesBySectionId[secId], index < arr.count {
                let it = arr[index]
                return PlayInput(contentsAlias: it.contentsAlias)
            } else if payload == .banner,
                      let arr = bannerEntitiesBySectionId[secId], index < arr.count {
                let it = arr[index]
                let alias = it.targetContentsAlias ?? it.contentsAlias ?? ""
                guard !alias.isEmpty else { return nil }
                return PlayInput(contentsAlias: alias, episodeAlias: it.targetEpisodeAlias)
            }
            return nil
            
        case .curation:
            if payload == .ongoing,
               let arr = ongoingEntitiesBySectionId[secId], index < arr.count {
                let it = arr[index]
                return PlayInput(contentsAlias: it.contentsAlias, episodeAlias: it.episodeAlias)
            } else if payload == .curation,
                      let arr = curationEntitiesBySectionId[secId], index < arr.count {
                let it = arr[index]
                return PlayInput(contentsAlias: it.contentsAlias)
            } else if payload == .ranking,
                      let arr = rankingEntitiesBySectionId[secId], index < arr.count {
                let it = arr[index]
                return PlayInput(contentsAlias: it.contentsAlias)
            }
            return nil
            
        case .allContents, .serialize:
            if payload == .curation,
               let arr = curationEntitiesBySectionId[secId], index < arr.count {
                let it = arr[index]
                return PlayInput(contentsAlias: it.contentsAlias)
            } else if payload == .ranking,
                      let arr = rankingEntitiesBySectionId[secId], index < arr.count {
                let it = arr[index]
                return PlayInput(contentsAlias: it.contentsAlias)
            } else if payload == .ongoing,
                      let arr = ongoingEntitiesBySectionId[secId], index < arr.count {
                let it = arr[index]
                return PlayInput(contentsAlias: it.contentsAlias, episodeAlias: it.episodeAlias)
            }
            return nil
        }
    }
    
    func fetchSectionList() {
        LZSnackConcurrencyManager
            .background { [weak self] in
                guard let self else { throw EmptyViewModelError.emptyViewModel }
                //  진열목록
                let list = try await self.curationUseCase.executeFetchCurationList()
                let sections = list.map { self.makeHomeSection(from: $0) }
                return (list, sections)
            }
            .onSuccess { [weak self] (list: [CurationItemDTO], sections: [HomeSection]) in
                guard let self else { return }
                
                self.sections = sections
                
                // ✅ 새 실행 버전 + 전체 호출 개수
                self.fetchVersion &+= 1
                let version = self.fetchVersion
                self.inflight = list.count  // 현재 구조상 모든 매핑타입이 네트워크를 태움
                
                // ✅ 섹션별 플레이스홀더 먼저 깔기
                for s in sections {
                    let ph = self.placeholderItems(for: s)
                    self.sectionsData = (s, ph)   // ← 섹션별로 먼저 placeholder 채우기
                }
                
                // 섹션별 API를 각 섹션마다 병렬로
                for (index, item) in list.enumerated() {
                    self.dispatchSectionJob(index: index, item: item, section: sections[index], version: version)
                }
            }
            .onError { [weak self] error in
                AppErrorHandler.handle(error)
            }
            .run()
    }
    
    //  진열 메타에 따라 어떤 API 태울지 결정
    private func dispatchSectionJob(index: Int, item: CurationItemDTO, section: HomeSection, version: Int) {
        switch item.mappingType {
        case "USER_DATA":
            // 유저 데이터 - 랭킹 조회
            loadRanking(index: index, section: section, item: item, version: version)
        case "SETTING_DATA":
            // FEATURED_BANNER / ORIGINAL_BANNER → 배너
            // ONGOING_CONTENTS → 연재중
            if item.settingInfo == "ONGOING_CONTENTS" {
                loadOngoing(index: index, section: section, version: version)
            } else {
                // 배너는 이 진열 아이템의 id를 curationId로 사용
                loadBanner(index: index, section: section, curationId: item.id, version: version)
            }
        case "PERSONAL_DATA":
            // 내가 시청중(이어보기)
            loadLastView(index: index, section: section, version: version)
        case "CONTENTS_DATA":
            // 콘텐츠(작품) 설정 조회 (curationId 필요)
            loadCurationContents(index: index, section: section, curationId: item.id, version: version)
        default:
            break
        }
    }
    private func loadBanner(index: Int, section: HomeSection, curationId: String, version: Int) {
        LZSnackConcurrencyManager
            .background { [weak self] in
                guard let self else { throw EmptyViewModelError.emptyViewModel }
                // DTO 호출
                let dtos = try await self.bannerUseCase.executeFetchContentsBanners(curationId: curationId)
                //  DTO → Entity
                let entities = dtos.map(ContentsBannerItemEntity.init(dto:))
                //  리스트 표시용 가벼운 UI 모델 생성
                let ui = entities.map {
                    HomeSectionEntity(
                        id: "\(section.id)#\($0.bannerId)", //$0.bannerId,
                        title: $0.bannerTitle,
                        thumbnailImagePath: $0.bannerImagePath
                    )
                }
                return (entities, ui)
            }
            .onSuccess { [weak self] (entities: [ContentsBannerItemEntity], ui: [HomeSectionEntity]) in
                guard let self else { return }
                //  엔티티 저장 (필요 시 DTO 저장은 유지/삭제 선택)
                self.bannerEntitiesBySectionId[section.id] = entities
                self.payloadKindBySectionId[section.id] = .banner
                self.sectionsData = (section, ui) // 해당 섹션만 교체
                self.finishOne(version)
            }
            .onError { [weak self] error in
                AppErrorHandler.handle(error)
                self?.finishOne(version)
            }
            .run()
    }
    
    private func loadRanking(index: Int, section: HomeSection, item: CurationItemDTO, version: Int) {
        LZSnackConcurrencyManager
            .background { [weak self] in
                guard let self else { throw EmptyViewModelError.emptyViewModel }
                
                let period = item.userDataSummeryPeriod ?? ""
                let type   = item.userDataType ?? ""
                let dtos   = try await self.rankingUseCase.executeFetchRanking(period: period, topN: 12, type: type)
                let entities = dtos.map(ContentsRankingItemEntity.init(dto:))
                let ui = entities.map {
                    HomeSectionEntity(
                        id: "\(section.id)#\($0.contentsId)", //$0.contentsId,
                        title: $0.contentsDetail?.title ?? $0.contentsAlias,
                        thumbnailImagePath: $0.contentsDetail?.coverImagePath
                    )
                }
                return (entities, ui)
            }
            .onSuccess { [weak self] (entities: [ContentsRankingItemEntity], ui: [HomeSectionEntity]) in
                guard let self else { return }
                self.rankingEntitiesBySectionId[section.id] = entities
                self.payloadKindBySectionId[section.id] = .ranking
                self.sectionsData = (section, ui)
                self.finishOne(version)
            }
            .onError { [weak self] error in
                AppErrorHandler.handle(error)
                self?.finishOne(version)
                
            }
            .run()
    }

    private func loadOngoing(index: Int, section: HomeSection, version: Int) {
        LZSnackConcurrencyManager
            .background { [weak self] in
                guard let self else { throw EmptyViewModelError.emptyViewModel }
                let dtos = try await self.ongoingUseCase.executeFetchContentsOngoing()
                let entities = dtos.map(ContentsOngoingItemEntity.init(dto:))
                let ui = entities.map {
                    HomeSectionEntity(
                        id: "\(section.id)#\($0.contentsId)",
                        title: $0.contentsAlias,
                        thumbnailImagePath: $0.coverImagePath
                    )
                }
                return (entities, ui)
            }
            .onSuccess { [weak self] (entities: [ContentsOngoingItemEntity], ui: [HomeSectionEntity]) in
                guard let self else { return }
                self.ongoingEntitiesBySectionId[section.id] = entities
                self.payloadKindBySectionId[section.id] = .ongoing
                self.sectionsData = (section, ui)
                self.finishOne(version)
            }
            .onError { [weak self] error in
                AppErrorHandler.handle(error)
                self?.finishOne(version)
            }
            .run()
    }
    
    private func loadLastView(index: Int, section: HomeSection, version: Int) {
        LZSnackConcurrencyManager
            .background { [weak self] in
                guard let self else { throw EmptyViewModelError.emptyViewModel }
                let dtos = try await self.lastWatchUseCase.executeFetchContentsLastWatch()
                let entities = dtos.map(ContentsLastWatchItemEntity.init(dto:)) // (오타명 유지)
                let ui = entities.map {
                    HomeSectionEntity(
                        id: "\(section.id)#\($0.contentsId)",
                        title: $0.contentsAlias,
                        thumbnailImagePath: $0.thumbnailUrl
                    )
                }
                return (entities, ui)
            }
            .onSuccess { [weak self] (entities: [ContentsLastWatchItemEntity], ui: [HomeSectionEntity]) in
                guard let self else { return }
                self.lastWatchEntitiesBySectionId[section.id] = entities
                self.payloadKindBySectionId[section.id] = .lastWatch
                self.sectionsData = (section, ui)
                self.finishOne(version)
            }
            .onError { [weak self] error in
                AppErrorHandler.handle(error)
                self?.finishOne(version)
            }
            .run()
    }
    
    private func loadCurationContents(index: Int, section: HomeSection, curationId: String, version: Int) {
        LZSnackConcurrencyManager
            .background { [weak self] in
                guard let self else { throw EmptyViewModelError.emptyViewModel }
                
                let dtos = try await self.curationContentsUseCase.executeFetchContentsCuration(curationId: curationId)
                let entities = dtos.map(ContentsCurationItemEntity.init(dto:))
                let ui = entities.map {
                    HomeSectionEntity(
                        id: "\(section.id)#\($0.contentsId)", //$0.contentsId,
                        title: $0.contentsDetail?.title ?? $0.contentsAlias,
                        thumbnailImagePath: $0.contentsDetail?.coverImagePath
                    )
                }
                return (entities, ui)
            }
            .onSuccess { [weak self] (entities: [ContentsCurationItemEntity], ui: [HomeSectionEntity]) in
                guard let self else { return }
                self.curationEntitiesBySectionId[section.id] = entities
                self.payloadKindBySectionId[section.id] = .curation
                self.sectionsData = (section, ui)
                self.finishOne(version)
            }
            .onError { [weak self] error in
                AppErrorHandler.handle(error)
                self?.finishOne(version)
            }
            .run()
    }
    
    //  layoutType / mappingType 규칙
    private func makeHomeSection(from item: CurationItemDTO) -> HomeSection {
        if item.mappingType == "PERSONAL_DATA" {
            return HomeSection(id: item.id,type: .watchHistory, headerTitle: item.title) // 시청중
        }
        let type: HomeSectionType
        switch item.layoutType {
        case "SLIDE":           type = .mainBanner    // 배너
        case "RANKING":         type = .ranking       // 랭킹
        case "THREE_ROW_LIST":  type = .allContents   // 3열 리스트
        case "CARD_SLIDE":      type = .original      // 카드 슬라이드
        case "ONE_ROW_LIST":    type = .curation      // 1열 리스트
        default:                type = .curation
        }
        return HomeSection(id: item.id, type: type, headerTitle: item.title)
    }
    
    // MARK: - Placeholder
    func placeholderItems(for section: HomeSection) -> [HomeSectionEntity] {
        func make(_ count: Int) -> [HomeSectionEntity] {
            (0..<count).map { i in
                HomeSectionEntity(
                    id: "ph:\(section.id)#\(i)", // ✅ 전역 유일 + placeholder 식별
                    title: "",
                    thumbnailImagePath: nil,
                    isPlaceholder: true
                )
            }
        }

        switch section.type {
        case .mainBanner:   return make(5)   // 배너는 5개 정도
        case .ranking:      return make(12)  // 랭킹 12
        case .watchHistory: return make(10)  // 이어보기 10
        case .original:     return make(5)   // 오리지널 5
        case .curation:     return make(10)  // 큐레이션 10
        case .allContents:  return make(9)   // 3x3 그리드
        case .serialize:    return make(9)
        }
    }
}
