//
//  SearchViewModel.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/9/25.
//
import Combine
import Alamofire
import Foundation

final class SearchViewModel {
    
    deinit {
        printX("메모리 해제")
    }
    
    @Published var searchContentsResult: [SearchContent]?
    
    // MARK: - 헤더(최근 검색어)
    @Published private(set) var recentKeywords: [String] = []
    
    private let searchUseCase: SearchUseCaseProtocol
    
    init(searchUseCase: SearchUseCaseProtocol) {
        self.searchUseCase = searchUseCase
    }
    
    func fetchInitialContent() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self = self else { return }
            let searchContent = try await searchUseCase.executeSearch(searchText: "인기")
            self.searchContentsResult = searchContent
            loadRecentKeywords()
        }
    }
    
    func searchContent(_ searchText: String) {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self = self else { return }
            let searchContent = try await searchUseCase.executeSearch(searchText: searchText)
            self.searchContentsResult = searchContent
            saveRecentKeyword(searchText)
        }
    }
    
    func loadRecentKeywords() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self = self else { return }
            let recentKeywords = try await searchUseCase.executeFetchRecentKeywords()
            self.recentKeywords = recentKeywords
        }
    }
    
    private func saveRecentKeyword(_ keyword: String) {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self = self else { return }
            await searchUseCase.executeSaveKeyword(keywordText: keyword)
            loadRecentKeywords()
        }
    }
    
    func deleteRecentKeyword(_ keyword: String) {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self = self else { return }
            await searchUseCase.executeDeleteKeyword(keywordText: keyword)
            loadRecentKeywords()
        }
    }
    
    func deleteAllRecentKeyword() {
        LZSnackConcurrencyManager.run { [weak self] in
            guard let self = self else { return }
            try await searchUseCase.executeDeleteAllKeyword()
            loadRecentKeywords()
        }
    }
}
