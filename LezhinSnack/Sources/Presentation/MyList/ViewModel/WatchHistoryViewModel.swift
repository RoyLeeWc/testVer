//
//  WatchHistoryViewModel.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/4/25.
//

import Combine

final class WatchHistoryViewModel {
    
    
    // MARK: - Inputs
    private let useCase: LastViewedMyListUseCaseProtocol
    private let deleteUseCase: DeleteLastViewedContentsUseCaseProtocol
    // 정렬 기준 (UI에서 바꿔주려면 public으로 바꿔도 됨)
    private(set) var currentSort: ContentsListSort = .recent
    
    // MARK: - 캐시 & 모드
    enum Mode { case paged, full }            // paged=서버 페이징, full=전체 캐시 표시
    private(set) var mode: Mode = .paged
    private var fullCache: [LastViewedContentItemEntity] = []
    private(set) var isAllLoaded: Bool = false        // isPaged=false 로 전체를 받은 적 있는가
    
    // 페이지 상태
    private(set) var page: Int = 0
    private let size: Int
    private(set) var sort: ContentsListSort
    
    // MARK: - Outputs
    @Published var items: [LastViewedContentItemEntity] = []
    @Published private(set) var hasMore: Bool = true
    @Published var errorMessage: String?
    @Published private(set) var isLoading: Bool = false
    
    // 외부에서 페이징 여부 체크용(VC에서 스크롤 시 호출)
    var canPaginate: Bool { mode == .paged && hasMore && !isLoading }
    
    init(useCase: LastViewedMyListUseCaseProtocol,
         deleteUseCase: DeleteLastViewedContentsUseCaseProtocol,
         pageSize: Int = 20,
         sort: ContentsListSort = .recent) {
        self.useCase = useCase
        self.deleteUseCase = deleteUseCase
        self.size = pageSize
        self.sort = sort
    }
    
    // 최초 로드: 이미 전체 캐시 있으면 그걸로, 아니면 페이징 0페이지
    func loadInitial() {
        guard !isLoading else { return }
        if isAllLoaded {
            mode = .full
            hasMore = false
            items = fullCache
            return
        }
        page = 0
        hasMore = true
        items.removeAll()
        fetch(isPaged: true, page: page, replace: true)
    }
    
    // 스크롤 페이징
    func loadNextPageIfNeeded(currentIndex: Int) {
        guard canPaginate else { return }
        if currentIndex >= items.count - 5 {
            page += 1
            fetch(isPaged: true, page: page, replace: false)
        }
    }
    
    // 편집 진입: 전체 로드(최초 1회만), 이후엔 캐시만 사용
    func enterEditMode() {
        guard !isLoading else { return }
        if isAllLoaded {
            mode = .full
            hasMore = false
            items = fullCache
            return
        }
        // 처음 편집 진입: isPaged=false 로 전체 1회 로드
        fetch(isPaged: false, page: 0, replace: true, onComplete: { [weak self] in
            guard let self = self else { return }
            self.fullCache = self.items
            self.isAllLoaded = true
            self.mode = .full
            self.hasMore = false
        })
    }
    
    // 당겨서 새로고침 등 “완전 갱신”이 필요할 때
    func hardRefresh() {
        fullCache.removeAll()
        isAllLoaded = false
        mode = .paged
        loadInitial()
    }
    
    // MARK: - Private
    private func fetch(isPaged: Bool, page: Int, replace: Bool, onComplete: (() -> Void)? = nil) {
        isLoading = true
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self = self else { return }
            do {
                let pageEntity = try await self.useCase.executeLastViewedContentsMyList(
                    size: self.size,
                    page: page,
                    sort: self.sort,
                    isPaged: isPaged
                )
                let newItems = pageEntity.items
                await MainActor.run {
                    if replace { self.items = newItems }
                    else { self.items.append(contentsOf: newItems) }
                    
                    // 서버 페이징 정보
                    self.hasMore = isPaged ? !pageEntity.isLast : false
                    self.isLoading = false
                    onComplete?()
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    //self.errorMessage = (error as NSError).localizedDescription
                }
            }
        }
    }
    
    func delete(items deleting: [LastViewedContentItemEntity], completion: @escaping (Bool)->Void) {
            let ids = deleting.map { $0.contentsId }
            guard !ids.isEmpty else { completion(true); return }

            LZSnackConcurrencyManager.run { [weak self] in
                guard let self = self else { return }
                // 서버 호출
                try await self.deleteUseCase.executeDeleteLastWatchViewedContentsMyList(contentsIds: ids)

                await MainActor.run {
                    // 현재 목록에서 제거
                    let idSet = Set(ids)
                    self.items.removeAll { idSet.contains($0.contentsId) }
                    // 전체 캐시에서도 제거
                    if self.fullCache != nil {
                        self.fullCache.removeAll { idSet.contains($0.contentsId) }
                    }
                    completion(true)
                }

            } onError: { [weak self] error in
                self?.errorMessage = error.localizedDescription
                completion(false)
            }
        }
    
    // 편집 종료: 호출 없음. 전체 캐시 그대로 표시
    func exitEditMode() {
        // 의도: 다시 페이징으로 돌아가지 않고 캐시 사용 유지
        mode = isAllLoaded ? .full : .paged
        if isAllLoaded {
            hasMore = false
            items = fullCache
        }
    }
    
    
    // 정렬 변경
    func updateSort(_ sort: ContentsListSort) {
        // 1) 정렬값 갱신
        self.sort = sort
        
        // 2) 모든 캐시/상태 리셋 → 페이징 모드로
        fullCache.removeAll()
        isAllLoaded = false
        mode = .paged
        
        // 3) 페이징 초기화
        page = 0
        hasMore = true
        items.removeAll()
        
        // 4) 서버에서 0페이지부터 다시
        fetch(isPaged: true, page: 0, replace: true)
    }
    
}
