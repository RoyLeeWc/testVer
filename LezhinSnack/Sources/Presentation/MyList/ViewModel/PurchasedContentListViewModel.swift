//
//  PurchasedContentListViewModel.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/4/25.
//

import Combine

final class PurchasedContentListViewModel {
    private let useCase: PurchasedContentsMyListUseCaseProtocol
    private let delCase: DeletePurchasedViewedContentsUseCaseProtocol
    
    // MARK: - Paging/Edit State
    private(set) var page: Int = 0
    private let size: Int
    private var hasMore: Bool = true
    private var mode: Mode = .paged
    private var allCache: [PurchasedContentItemEntity]?
    private(set) var sort: ContentsListSort
    
    enum Mode { case paged, full }
    
    // MARK: - Outputs
    @Published private(set) var items: [PurchasedContentItemEntity] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published private(set) var canPaginate: Bool = true
    
    
    @Published var purchasedContentList: [PurchasedContentItemEntity]?
    
    init(useCase: PurchasedContentsMyListUseCaseProtocol, deleteUseCase: DeletePurchasedViewedContentsUseCaseProtocol, pageSize: Int = 20, sort: ContentsListSort = .recent) {
        self.useCase = useCase
        self.delCase = deleteUseCase
        self.size = pageSize
        self.sort = sort
    }
    
    // 최초 진입 / 당김 새로고침
    func loadInitial() {
        guard !isLoading else { return }
        // 편집에서 전체 캐시를 만든 적 있다면, 그대로 보여주기
        if let cache = allCache {
            mode = .full
            canPaginate = false
            hasMore = false
            items = cache
            return
        }
        page = 0
        hasMore = true
        mode = .paged
        canPaginate = true
        fetch(isPaged: true, page: 0, replace: true)
    }
    
    func loadNextPageIfNeeded(currentIndex: Int) {
        guard mode == .paged, canPaginate, !isLoading, hasMore else { return }
        if currentIndex >= items.count - 5 {
            fetch(isPaged: true, page: page + 1, replace: false)
        }
    }
    
    func hardRefresh() {
        allCache = nil
        page = 0
        hasMore = true
        mode = .paged
        canPaginate = true
        fetch(isPaged: true, page: 0, replace: true)
    }
    
    // 편집 진입: 전체 로드(최초 1회만), 이후 캐시 재사용
    func enterEditMode() {
        canPaginate = false
        if let cache = allCache {
            mode = .full
            hasMore = false
            items = cache
            return
        }
        fetch(isPaged: false, page: 0, replace: true, cacheAll: true, forceNoMore: true)
    }
    
    func exitEditMode() {
        if allCache != nil {
            mode = .full
            canPaginate = false
            hasMore = false
        } else {
            mode = .paged
            canPaginate = true
        }
    }
    
    func updateSort(_ sort: ContentsListSort) {
        self.sort = sort
        // 정렬 변경 시 캐시/상태 리셋 후 0페이지부터 서버 호출
        allCache = nil
        page = 0
        hasMore = true
        mode = .paged
        canPaginate = true
        fetch(isPaged: true, page: 0, replace: true)
    }
    
    func delete(items targetItems: [PurchasedContentItemEntity], completion: @escaping (Bool)->Void) {
        let ids = targetItems.map { $0.contentsId }
        guard !ids.isEmpty else { completion(true); return }
        
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            try await self.delCase.executeDeletePurchasedViewedContentsMyList(contentsIds: ids)
            await MainActor.run {
                let idSet = Set(ids)
                self.items.removeAll { idSet.contains($0.contentsId) }
                self.allCache?.removeAll { idSet.contains($0.contentsId) }
                completion(true)
            }
        } onError: { [weak self] error in
            self?.errorMessage = error.localizedDescription
            completion(false)
        }
    }
    
    // MARK: - Private
    private func fetch(
        isPaged: Bool,
        page: Int,
        replace: Bool,
        cacheAll: Bool = false,
        forceNoMore: Bool = false
    ) {
        isLoading = true
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            let pageEntity = try await self.useCase.executeFetchPurchasedContents(
                size: self.size,
                page: page,
                sort: self.sort,
                isPaged: isPaged
            )
            await MainActor.run {
                if replace { self.items = pageEntity.items }
                else { self.items.append(contentsOf: pageEntity.items) }
                
                if cacheAll { self.allCache = self.items }
                
                self.page = page
                self.hasMore = forceNoMore ? false : !pageEntity.isLast
                self.canPaginate = (self.mode == .paged) && self.hasMore
                self.isLoading = false
            }
        } onError: { [weak self] error in
            self?.isLoading = false
            self?.errorMessage = error.localizedDescription
        }
    }
}
