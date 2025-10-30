//
//  ViewerViewModel.swift
//  LezhinSnack
//
//  Created by lwc on 9/19/25.
//
import Foundation
import Combine
import SwiftyUserDefaults

/// Home에서 넘어온 초기 진입 정보
struct ViewerInput {
    /// 어떤 컨텐츠인지 (alias)
    let contentsAlias: String
    /// 처음 열 회차 alias (없으면 상세의 firstEpisodeAlias 사용)
    let initialEpisodeAlias: String?
    /// 홈에서 선취득한 상세
    let detail: DisplayContentsDetailEntity?
    /// 홈에서 선취득한 회차 목록
    let episodes: [ContentsEpisodeEntity]?
}

struct ViewerUIError: LocalizedError {
    let message: String
    let code: String
    var errorDescription: String? { message }
}

enum ViewerMode { case main, tasted }

/// 셀에 내려줄 최소 상태(지금은 뼈대만)
struct ViewerItemState: Hashable {
    let episodeId: String
    let episodeAlias: String
    let index: Int
}

struct ViewerPlayback: Equatable {
    let episodeId: String
    let contentId: String
    let videoId: String
    let manifestURL: URL
    let drmToken: String
    let cfCookieHeader: String?
}

final class ViewerViewModel {
    
    // MARK: Dependencies (UseCases만 주입, DI에서 네트워크 호출 없음)
    private let fetchContentsDetailUseCase: FetchContentsDetailUseCaseProtocol
    private let fetchEpisodesUseCase: FetchContentsEpisodesUseCaseProtocol
    private let displayVideoUseCase: DisplayVideoUseCaseProtocol
    private let likeContentsUseCase: LikeContentsUseCaseProtocol
    private let unlikeContentsUseCase: UnlikeContentsUseCaseProtocol
    private let favoriteUseCase: FavoriteContentsUseCaseProtocol
    private let unfavoriteUseCase: UnfavoriteContentsUseCaseProtocol
    private let trackEpisodeViewUseCase: TrackEpisodeViewUseCaseProtocol
    private let purchasedEpisodesUseCase: PurchasedEpisodesUseCaseProtocol
    private let previewRecommendationsUseCase: FetchPreviewRecommendationsUseCaseProtocol
    // MARK: State
    private let mode: ViewerMode = .main
    // 인덱스 단위 상세 인플라이트 가드
    @MainActor
    private var inflightDetailIndices = Set<Int>()
    // --- mainViewer 기존 필드 유지 ---
    @Published private(set) var detail: DisplayContentsDetailEntity? // main 전용
    // --- tastedViewer 전용 보관소 ---
    @Published private(set) var tastedGroup: PreviewRecommendationEntity? // 프리뷰 결과 원본
    @Published private(set) var tastedItems: [PreviewRecommendationItem] = []
    private var detailsByIndex: [Int: DisplayContentsDetailEntity] = [:]
    // 상세가 준비되면 셀/VC에서 UI 즉시 갱신하고 싶을 때 쓰는 신호
    let didPrepareDetail = PassthroughSubject<Int, Never>()
    // 이미 본(끝까지 본) 에피소드 추적 – 새 목록에서 가능하면 제외
    private var seenEpisodeIds = Set<String>()
    @Published private(set) var isRefreshingTasted = false
    private var tastedRefreshInFlight = false
    
    // 공통
    @Published private(set) var items: [ViewerItemState] = []
    @Published private(set) var centerIndex: Int = 0
    // 찜목록에 필요한 회차정보
    private(set) var currentIndex: Int = 0
    // episodeId set
    private var viewCountSent = Set<String>()
    // 구매한 에피소드 ID 집합 (UI에서 쉽게 참조하도록 공개)
    @Published private(set) var purchasedEpisodeIds: Set<String> = []
    
    let keepEpisodeIds = CurrentValueSubject<Set<String>, Never>([])
    
    let errors = PassthroughSubject<Error, Never>()
    /// 특정 index의 재생정보가 준비되면 쏴줌 (VC가 해당 셀 업데이트에 사용)
    let didPreparePlayback = PassthroughSubject<Int, Never>()
    
    // MARK: Internal caches
    @Published private(set) var episodes: [ContentsEpisodeEntity] = []
    private var aliasToIndex: [String: Int] = [:]
    private var playbackCache: [String: ViewerPlayback] = [:]           // episodeId -> playback
    private var inflightEpisodeIds = Set<String>()                       // 중복 호출 방지
    
    // DRM 파라미터
    private let drmType = "FAIRPLAY"
    private var drmLicenseUserId: String{ "\(AppContext.shared.deviceUniqueID)" }
    
    private var likeInFlight = false
    // ✅ 현재 뷰어 타입 보관 (프리로드 분기에 사용)
    private(set) var viewerType: ViewerType = .mainViewer
    
    init(fetchContentsDetailUseCase: FetchContentsDetailUseCaseProtocol,
         fetchEpisodesUseCase: FetchContentsEpisodesUseCaseProtocol,
         displayVideoUseCase: DisplayVideoUseCaseProtocol,
         likeContentsUseCase: LikeContentsUseCaseProtocol,
         unlikeContentsUseCase: UnlikeContentsUseCaseProtocol,
         favoriteUseCase: FavoriteContentsUseCaseProtocol,
         unfavoriteUseCase: UnfavoriteContentsUseCaseProtocol,
         trackEpisodeViewUseCase: TrackEpisodeViewUseCaseProtocol,
         purchasedEpisodesUseCase: PurchasedEpisodesUseCaseProtocol,
         previewRecommendationsUseCase: FetchPreviewRecommendationsUseCaseProtocol)
    {
        self.fetchContentsDetailUseCase = fetchContentsDetailUseCase
        self.fetchEpisodesUseCase = fetchEpisodesUseCase
        self.displayVideoUseCase = displayVideoUseCase
        self.likeContentsUseCase = likeContentsUseCase
        self.unlikeContentsUseCase = unlikeContentsUseCase
        self.favoriteUseCase = favoriteUseCase
        self.unfavoriteUseCase = unfavoriteUseCase
        self.trackEpisodeViewUseCase = trackEpisodeViewUseCase
        self.purchasedEpisodesUseCase = purchasedEpisodesUseCase
        self.previewRecommendationsUseCase = previewRecommendationsUseCase
    }
    // ✅ 라우트 스타트 추가 (VC에서 이걸 호출)
    @MainActor
    func start(route: ViewerRoute) {
        switch route {
        case .main(let input):
            viewerType = .mainViewer
            start(input: input)                 // ← 메인
        case .tasted:
            viewerType = .tastedViewer
            Task { await loadTastedInitial() }  // ← 맛보기 초기화 진입
        }
    }
    
    @MainActor
    func start(input: PlayInput) {
        Task { [weak self] in
            guard let self else { return }
            do {
                // 1) detail/episodes 확보
                
                let eps: [ContentsEpisodeEntity]
                
                let fetchedDetail = try await fetchContentsDetailUseCase.executeFetchContentsDetail(alias: input.contentsAlias)
                let fetchedEpisodes = try await fetchEpisodesUseCase.executeFetchContentsEpisodes(contentsId: fetchedDetail.id)
                
                detail = fetchedDetail
                eps = fetchedEpisodes
                // 2) 내부 상태 구성
                self.episodes = eps
                self.aliasToIndex = Dictionary(uniqueKeysWithValues: eps.enumerated().map { ($0.element.alias, $0.offset) })
                // 2) 구매 회차 집합
                do {
                    let list = try await purchasedEpisodesUseCase.executeFetchPurchasedEpisodes(contentsId: fetchedDetail.id)
                    self.purchasedEpisodeIds = Set(list.map(\.episodeId))
                } catch {
                    // 실패해도 치명적이지 않으니 로깅 후 빈 Set 유지
                    print("purchased ids fetch failed:", error)
                }
                // 3) items 구성
                let mapped: [ViewerItemState] = eps.enumerated().map { idx, e in
                    ViewerItemState(episodeId: e.episodeId, episodeAlias: e.alias, index: idx)
                }
                self.items = mapped
                
                // 4) 초기 센터 index 산출물
                let initialAlias = input.episodeAlias ?? detail?.firstEpisodeAlias ?? "1"

                // aliasToIndex에서 초기 회차 찾기
                if let foundIndex = self.aliasToIndex[initialAlias] {
                    self.centerIndex = min(max(0, foundIndex), max(0, mapped.count - 1))
                    print("✅ [ViewerViewModel] 초기 회차 설정: alias=\(initialAlias) → index=\(foundIndex)")
                } else {
                    // ⚠️ 매핑에서 찾지 못함 - fallback to 0
                    self.centerIndex = 0
                    print("⚠️ [ViewerViewModel] 초기 회차 alias '\(initialAlias)'를 찾을 수 없어 첫 번째 회차로 fallback")
                    print("   사용 가능한 alias 목록: \(Array(self.aliasToIndex.keys.sorted()))")
                }
                
                // 5) 3칸 프리로드
                await self.preloadWindow(around: self.centerIndex)
            }catch let ContentsRepositoryError.api(code, message) {
                await MainActor.run { self.errors.send(ViewerUIError(message: message, code: code)) }
            } catch {
                await MainActor.run { self.errors.send(error) }
            }
            
        }
        
    }
    
    @MainActor
    func move(to newCenter: Int) {
        guard !items.isEmpty else { return }
        let bounded = min(max(0, newCenter), items.count - 1)
        currentIndex = max(0, min(newCenter, items.count - 1))
        centerIndex = bounded
        Task { [weak self] in
            await self?.preloadWindow(around: bounded)
        }
    }
    
    /// VC가 셀 갱신 시 호출하는 헬퍼
    func playback(at index: Int) -> ViewerPlayback? {
        guard items.indices.contains(index) else { return nil }
        let epId = items[index].episodeId
        return playbackCache[epId]
    }
    
    // MARK: Preload Core
    /// center 기준으로 [center-1, center, center+1]만 보장 (이미 준비/요청 중이면 스킵)
    /// ✅ Center를 먼저 로드하여 Race Condition 방지
    @MainActor
    private func preloadWindow(around center: Int) async {
        let indices = [center-1, center, center+1].filter { items.indices.contains($0) }

        // shrink 용 keep 먼저 전송
        keepEpisodeIds.send(Set(indices.map { items[$0].episodeId }))

        // ✅ STEP 1: Center (현재 보는 비디오) 먼저 로드 - 우선순위 보장
        if indices.contains(center) {
            if self.viewerType == .tastedViewer {
                await self.ensurePreparedTasted(index: center)
            } else {
                await self.ensurePrepared(index: center)
            }
        }

        // ✅ STEP 2: 양옆 비디오를 병렬로 로드
        let sideIndices = indices.filter { $0 != center }
        guard !sideIndices.isEmpty else { return }

        await withTaskGroup(of: Void.self) { group in
            for idx in sideIndices {
                group.addTask { [weak self] in
                    guard let self else { return }
                    if self.viewerType == .tastedViewer {
                        await self.ensurePreparedTasted(index: idx)   // ✅ 맛보기 전용
                    } else {
                        await self.ensurePrepared(index: idx)         // 기존(main)
                    }
                }
            }
        }

    }
    
    // 마지막 셀 재생 완료에서 호출
    @MainActor
    func tastedPlaybackDidFinish(at index: Int) {
        guard viewerType == .tastedViewer,
              items.indices.contains(index) else { return }
        
        // 시청 완료 표시
        seenEpisodeIds.insert(items[index].episodeId)
        
        // 마지막인지 판별
        if index == items.count - 1 {
            Task { await refreshTastedFeed() }
        } else {
            // 마지막이 아니면 다음으로 스냅(원하면 유지)
            move(to: index + 1)
        }
    }
    
    @MainActor
    func refreshTastedFeed() async {
        guard viewerType == .tastedViewer, !tastedRefreshInFlight else { return }
        tastedRefreshInFlight = true
        isRefreshingTasted = true
        defer {
            tastedRefreshInFlight = false
            isRefreshingTasted = false
        }
        
        do {
            let rec = try await previewRecommendationsUseCase.executeFetchPreviewRecommendations()
            
            // 이미 본 에피소드는 가능하면 제외 (전부 걸러지면 그대로 사용)
            let filtered = rec.items.filter { !self.seenEpisodeIds.contains($0.episodeId) }
            let nextItems = filtered.isEmpty ? rec.items : filtered
            
            // 상태 초기화
            self.tastedGroup = rec
            self.tastedItems = nextItems
            self.detailsByIndex.removeAll()
            self.playbackCache.removeAll()
            self.inflightEpisodeIds.removeAll()
            self.inflightDetailIndices.removeAll()
            
            // items 재구성
            self.items = nextItems.enumerated().map { idx, it in
                ViewerItemState(
                    episodeId: it.episodeId,
                    episodeAlias: it.contentsAlias,   // alias 필드에는 contentsAlias를 넣어두는 현재 구조 유지
                    index: idx
                )
            }
            
            // 맨 앞으로 세팅 + 프리로드
            self.centerIndex = 0
            
            // shrink 관점에서 이전 셀들 비우도록
            self.keepEpisodeIds.send([])
            
            await self.preloadWindow(around: 0)
            
        } catch {
            errors.send(error)
        }
    }
    

    @MainActor
    private func gateStartPrepare(index: Int) -> String? {
        guard items.indices.contains(index) else { return nil }
        let epId = items[index].episodeId
        if playbackCache[epId] != nil { return nil }
        if inflightEpisodeIds.contains(epId) { return nil }
        inflightEpisodeIds.insert(epId)               // ✅ 공유 Set 변경: 메인에서만
        return epId
    }

    @MainActor
    private func gateFinishPrepareSuccess(epId: String, pb: ViewerPlayback, index: Int) {
        playbackCache[epId] = pb                      // ✅ 공유 Dictionary 변경: 메인에서만
        inflightEpisodeIds.remove(epId)
        didPreparePlayback.send(index)
    }

    @MainActor
    private func gateFinishPrepareFail(epId: String) {
        inflightEpisodeIds.remove(epId)
    }
    
    @MainActor
    func tastedDetail(at index: Int) -> DisplayContentsDetailEntity? {
        detailsByIndex[index]
    }
    
    @MainActor
    private func ensureTastedDetail(index: Int) async {
        guard viewerType == .tastedViewer,
              tastedItems.indices.contains(index) else { return }
        if detailsByIndex[index] != nil { return }
        if inflightDetailIndices.contains(index) { return }
        inflightDetailIndices.insert(index)
        defer { inflightDetailIndices.remove(index) }

        let alias = tastedItems[index].contentsAlias
        do {
            let d = try await fetchContentsDetailUseCase.executeFetchContentsDetail(alias: alias)
            detailsByIndex[index] = d
            didPrepareDetail.send(index)   // ✅ 셀 메타 즉시 갱신(좋아요/찜/타이틀 등)
        } catch {
            // 필요시 로깅/토스트만
            errors.send(error)
        }
    }
    
    // 재생 준비 전용 (기존 ensurePrepared 기능 그대로)
    private func ensurePlayback(index: Int) async {
        guard let epId = await gateStartPrepare(index: index) else { return }

        do {
            let v = try await displayVideoUseCase.executeFetchDisplayVideo(
                episodeId: epId,
                drmType: .fairplay,
                drmLicenseUserId: drmLicenseUserId
            )

            // ✅ URL 안전 변환 (한글, 특수문자, 1080p 등 처리)
            guard let url = URLEncodingHelper.safeURL(from: v.manifestPath) else {
                await gateFinishPrepareFail(epId: epId)
                await MainActor.run {
                    self.errors.send(ViewerUIError(message: "Invalid manifest URL: \(v.manifestPath)", code: "URL_PARSE_ERROR"))
                }
                return
            }
            let pb = ViewerPlayback(
                episodeId: v.episodeId,
                contentId: v.contentsId,
                videoId: v.videoId,
                manifestURL: url,
                drmToken: v.drmToken,
                cfCookieHeader: v.cfCookieHeader
            )
            await gateFinishPrepareSuccess(epId: epId, pb: pb, index: index)
        } catch let ContentsRepositoryError.api(code, message) {
            //  레포 에러 직접 처리
            await gateFinishPrepareFail(epId: epId)
            await MainActor.run {
                self.errors.send(ViewerUIError(message: message, code: code))
            }
        } catch {
            await gateFinishPrepareFail(epId: epId)
            await MainActor.run { errors.send(error) }
        }
    }
    
    /// 단일 index 준비 – 캐시/인플라이트 체크 후 네트워크
    private func ensurePrepared(index: Int) async {
        // ❶ 메인에서 안전하게 epId를 "예약"
        guard let epId = await gateStartPrepare(index: index) else { return }

        do {
            // ❷ 네트워크는 백그라운드에서
            let v = try await displayVideoUseCase.executeFetchDisplayVideo(
                episodeId: epId,
                drmType: DRMType(rawValue: drmType) ?? .fairplay,
                drmLicenseUserId: drmLicenseUserId
            )

            // ✅ URL 안전 변환 (한글, 특수문자, 1080p 등 처리)
            guard let url = URLEncodingHelper.safeURL(from: v.manifestPath) else {
                await gateFinishPrepareFail(epId: epId)
                await MainActor.run {
                    self.errors.send(ViewerUIError(message: "Invalid manifest URL: \(v.manifestPath)", code: "URL_PARSE_ERROR"))
                }
                return
            }
            
            let pb = ViewerPlayback(
                episodeId: v.episodeId,
                contentId: v.contentsId,
                videoId: v.videoId,
                manifestURL: url,
                drmToken: v.drmToken,
                cfCookieHeader: v.cfCookieHeader
            )
            
            // ❸ 결과 반영도 메인에서만
            await gateFinishPrepareSuccess(epId: epId, pb: pb, index: index)
            
        } catch let ContentsRepositoryError.api(code, message) {
            //  레포 에러 직접 처리
            await gateFinishPrepareFail(epId: epId)
            await MainActor.run {
                self.errors.send(ViewerUIError(message: message, code: code))
            }
        } catch {
            await gateFinishPrepareFail(epId: epId)
            await MainActor.run { errors.send(error) }
        }
    }
    
    @MainActor
    func toggleFavorite() async {
        
        if viewerType == .tastedViewer {
            let idx = currentIndex
            guard var tastedViewerDetail = detailsByIndex[idx] else { return }
            let contentsId = tastedViewerDetail.id
            let episodeId  = items[idx].episodeId
            let wasFavorite = tastedViewerDetail.isFavorite

            tastedViewerDetail.isFavorite.toggle()
            detailsByIndex[idx] = tastedViewerDetail
            didPrepareDetail.send(idx)
            
            do {
                if tastedViewerDetail.isFavorite {
                    try await favoriteUseCase.executeFavoriteContents(contentsId: contentsId, episodeId: episodeId)
                } else {
                    try await unfavoriteUseCase.executeUnfavoriteContents(contentsId: contentsId)
                }
            } catch {
                // 롤백
                var rb = detailsByIndex[idx]
                rb?.isFavorite = wasFavorite
                detailsByIndex[idx] = rb
                didPrepareDetail.send(idx)
                errors.send(error)
            }
            return
        }
        
        guard var d = detail else { return }
        let contentsId = d.id
        if d.isFavorite {
            // 취소
            do {
                try await unfavoriteUseCase.executeUnfavoriteContents(contentsId: contentsId)
                d.isFavorite = false
                detail = d
            } catch {
                errors.send(error)
            }
        } else {
            // 등록: 현재 보고있는 회차 id 필요
            guard items.indices.contains(currentIndex) else { return }
            let episodeId = items[currentIndex].episodeId
            do {
                try await favoriteUseCase.executeFavoriteContents(contentsId: contentsId, episodeId: episodeId)
                d.isFavorite = true
                detail = d
            } catch {
                errors.send(error)
            }
        }
    }
    
    @MainActor
    func likeTapped() {
        if viewerType == .tastedViewer {
            let idx = currentIndex
            guard var tastedViewerDetail = detailsByIndex[idx] else { return }
            let contentsId = tastedViewerDetail.id
            let wasLiked = tastedViewerDetail.isLiked
            let oldCount = tastedViewerDetail.likesCount
            
            
            tastedViewerDetail.isLiked.toggle()
            tastedViewerDetail.likesCount = max(0, oldCount + (tastedViewerDetail.isLiked ? 1 : -1))
            detailsByIndex[idx] = tastedViewerDetail
            didPrepareDetail.send(idx)
            
            Task {
                do {
                    if tastedViewerDetail.isLiked {
                        try await likeContentsUseCase.executeLikeContents(contentsId: contentsId)
                    } else {
                        try await unlikeContentsUseCase.executeUnlikeContents(contentsId: contentsId)
                    }
                } catch {
                    await MainActor.run {
                        var rollback = self.detailsByIndex[idx]
                        rollback?.isLiked = wasLiked
                        rollback?.likesCount = oldCount
                        self.detailsByIndex[idx] = rollback
                        self.didPrepareDetail.send(idx)
                        self.errors.send(error)
                    }
                }
            }
            return
        }
        
        guard var detail = detail else { return }
        guard !likeInFlight else { return }
        likeInFlight = true
        
        let contentsId = detail.id
        let wasLiked = detail.isLiked
        let oldCount = detail.likesCount
        
        detail.isLiked.toggle()
        detail.likesCount = max(0, oldCount + (detail.isLiked ? 1 : -1))
        self.detail = detail
        
        Task {
            do {
                if detail.isLiked {
                    try await likeContentsUseCase.executeLikeContents(contentsId: contentsId)
                } else {
                    try await unlikeContentsUseCase.executeUnlikeContents(contentsId: contentsId)
                }
            } catch {
                // 2) 실패 시 롤백
                await MainActor.run {
                    var rollback = self.detail
                    rollback?.isLiked = wasLiked
                    rollback?.likesCount = oldCount
                    self.detail = rollback
                    self.errors.send(error)
                }
            }
            await MainActor.run { self.likeInFlight = false }
        }
    }
   
    
    
    @MainActor
    func trackViewIfNeeded(contentsId: String, episodeId: String, tastedMode: Bool) async {
        // 중복 방지
        if viewCountSent.contains(episodeId) { return }
        viewCountSent.insert(episodeId)
        
        // 구독 정보가 있다면 채워서 보내기 (없으면 nil)
        let sub: EpisodeViewCountAPIRequest.SubscriptionInfo? = nil
        // 예: 필요 시 계정/상품 정보에서 채워 넣기
        // let sub = .init(subscriptionId: "...", productCode: "...")
        
        do {
            try await trackEpisodeViewUseCase.executeTrackEpisodeView(contentsId: contentsId,
                                                                      episodeId: episodeId,
                                                                      subscriptionInfo: sub,
                                                                      isViewCountOnly: tastedMode)
        } catch {
            // 실패시 세트에서 제거해서 재시도 가능하게
            viewCountSent.remove(episodeId)
            // 로깅만 하고 UI에러는 굳이 띄우지 않음(카운트 성격)
            print("⚠️ view count send failed:", error)
        }
    }
    
    // 1) 맛보기 목록 불러오기
    @MainActor
    func loadTastedInitial() async {
        do {
            let rec = try await previewRecommendationsUseCase.executeFetchPreviewRecommendations()
            // 그룹/아이템 분리 저장
            self.tastedGroup = rec
            self.tastedItems = rec.items

            // 셀에 내려줄 item state 구성 (이제 rec.items 사용)
            self.items = rec.items.enumerated().map { idx, it in
                ViewerItemState(
                    episodeId: it.episodeId,
                    episodeAlias: it.contentsAlias,
                    index: idx
                )
            }
            self.centerIndex = 0
        } catch {
            errors.send(error)
            return
        }
        await preloadWindow(around: 0)
    }

    private func ensurePreparedTasted(index: Int) async {
        // ✅ 상세 먼저 보장 (메인액터 + 인플라이트 가드 포함)
        await ensureTastedDetail(index: index)
        
        // ✅ 재생 준비 (게이트)
        guard let epId = await gateStartPrepare(index: index) else { return }
        do {
            let v = try await displayVideoUseCase.executeFetchDisplayVideo(
                episodeId: epId, drmType: .fairplay, drmLicenseUserId: drmLicenseUserId
            )
            guard let url = URL(string: v.manifestPath) else {
                await gateFinishPrepareFail(epId: epId)
                return
            }
            let pb = ViewerPlayback(
                episodeId: v.episodeId,
                contentId: v.contentsId,
                videoId: v.videoId,
                manifestURL: url,
                drmToken: v.drmToken,
                cfCookieHeader: v.cfCookieHeader
            )
            await gateFinishPrepareSuccess(epId: epId, pb: pb, index: index)
        } catch let ContentsRepositoryError.api(code, message) {
            //  레포 에러 직접 처리
            await gateFinishPrepareFail(epId: epId)
            await MainActor.run {
                self.errors.send(ViewerUIError(message: message, code: code))
            }
        }
        catch {
            await gateFinishPrepareFail(epId: epId)
            await MainActor.run { self.errors.send(error) }
        }
    }

    
    private func resolveEpisodeIdForTasted(index: Int) async throws -> (String, String) {
        guard let d = detailsByIndex[index] else {
            throw NSError(domain: "Viewer", code: -1, userInfo: [NSLocalizedDescriptionKey: "detail not loaded"])
        }
        
        // 우선순위: 상세의 firstEpisodeAlias → 없으면 "1"(서버 규칙에 맞게 조정)
        let targetAlias = (d.firstEpisodeAlias?.isEmpty == false) ? d.firstEpisodeAlias! : "1"
        
        // 최소 호출 원칙: 전체 목록 선조회는 하지 않지만, alias → id 매핑이 필요하므로
        // 해당 컨텐츠에 한해 1회만 목록을 받아서 매핑 (게으른 호출)
        // (fetchContentsEpisodesUseCase는 이미 DI에 있고, 네가 “목록조회 api는 필요없다”고 한 취지 유지:
        //  전역 선조회가 아니라 ‘필요할 때만, 그 컨텐츠에 한해’ 조회)
        let eps = try await fetchEpisodesUseCase.executeFetchContentsEpisodes(contentsId: d.id)
        
        if let matched = eps.first(where: { $0.alias == targetAlias })?.episodeId {
            return (matched, targetAlias)
        }
        
        // 매칭 실패 → 첫 회차로 폴백
        if let fallbackId = eps.first?.episodeId, let fallbackAlias = eps.first?.alias {
            return (fallbackId, fallbackAlias)
        }
        
        // 정말 없으면 에러
        throw NSError(domain: "Viewer", code: -2, userInfo: [NSLocalizedDescriptionKey: "no episodes"])
    }
    
}
