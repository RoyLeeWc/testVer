//
//  WishListViewModel.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/4/25.
//
import Combine

final class WishListViewModel {
    private let useCase: WishContentsMyListUseCaseProtocol
    private let delCase: DeleteWishViewedContentsUseCaseProtocol
    
    // MARK: - Paging/Edit State
    private(set) var page: Int = 0
    private let size: Int
    private var hasMore: Bool = true
    private(set) var sort: ContentsListSort = .recent
    
    // 편집모드에서 전체로딩한 결과 캐시
    private var allCache: [WishContentItemEntity]?
    
    // 편집모드일 땐 스크롤 페이징 끔
    @Published private(set) var canPaginate: Bool = true
    
    // MARK: - Outputs
    @Published private(set) var items: [WishContentItemEntity] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    
    
    @Published var wishList: [WishContentItemEntity]?
    
    init(useCase: WishContentsMyListUseCaseProtocol, deleteUseCase: DeleteWishViewedContentsUseCaseProtocol, pageSize: Int = 20) {
        self.useCase = useCase
        self.delCase = deleteUseCase
        
        self.size = pageSize
    }
    
    // 최초 진입 / 당김 새로고침 (페이징 모드)
    func loadInitial() {
        guard !isLoading else { return }
        page = 0
        hasMore = true
        fetch(isPaged: true, page: 0, replace: true)
    }
    
    // 무한 스크롤
    func loadNextPageIfNeeded(currentIndex: Int) {
        guard canPaginate, !isLoading, hasMore else { return }
        if currentIndex >= items.count - 5 {
            fetch(isPaged: true, page: page + 1, replace: false)
        }
    }
    
    // 하드 리프레시(캐시까지 무효)
    func hardRefresh() {
        allCache = nil
        loadInitial()
    }
    
    // 정렬 변경: 항상 서버 재요청
    func updateSort(_ newSort: ContentsListSort) {
        // 정렬 바뀌면 캐시 무효화 + 페이징 리셋 + 재요청
        sort = newSort
        allCache = nil
        canPaginate = true
        loadInitial()
    }
    
    // 편집 진입: 전체 로드(isPaged=false). 처음 1회만 서버호출, 이후 캐시 재사용
    func enterEditMode() {
        canPaginate = false
        if let cache = allCache {
            items = cache
            return
        }
        fetch(isPaged: false, page: 0, replace: true, forceHasMoreFalse: true, cacheAll: true)
    }
    
    // 편집 종료: 서버 재호출 없음(정책상 유지)
    func exitEditMode() {
        canPaginate = true
        // 화면은 현재 items 그대로 유지 (필요 시 loadInitial()로 바꿔도 됨)
    }
    
    // 삭제
    func delete(items targetItems: [WishContentItemEntity], completion: @escaping (Bool) -> Void) {
        let ids = targetItems.map { $0.contentsId }
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
            try await self.delCase.executeDeleteWishViewedContentsMyList(contentsIds: ids)
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
    private func fetch(isPaged: Bool, page: Int, replace: Bool, forceHasMoreFalse: Bool = false, cacheAll: Bool = false) {
        isLoading = true
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self else { return }
 
            let pageEntity = try await self.useCase.executeFavoriteContentsMyList(size: self.size, page: page, sort: self.sort, isPaged: isPaged)
            
            await MainActor.run {
                if replace {
                    self.items = pageEntity.items
                } else {
                    self.items.append(contentsOf: pageEntity.items)
                }
                
                if cacheAll { self.allCache = self.items }
                
                self.page = page
                self.hasMore = forceHasMoreFalse ? false : !pageEntity.isLast
                self.isLoading = false
            }
        } onError: { [weak self] error in
            self?.isLoading = false
            self?.errorMessage = error.localizedDescription
        }
    }
}
