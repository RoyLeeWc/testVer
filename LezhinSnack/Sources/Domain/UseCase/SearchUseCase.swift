//
//  SearchUseCase.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/10/25.
//

import Foundation

protocol SearchUseCaseProtocol {
    func executeSearch(searchText: String) async throws -> [SearchContent]
    func executeFetchRecentKeywords() async throws -> [String]
    func executeSaveKeyword(keywordText: String) async
    func executeDeleteKeyword(keywordText: String) async
    func executeDeleteAllKeyword() async throws
}
    
    
class SearchUseCase: SearchUseCaseProtocol {
    
    
    private let repository: SearchRepositoryProtocol
    
    init(searchRepository: SearchRepositoryProtocol) {
        self.repository = searchRepository
    }
    
    func executeSearch(searchText: String) async throws -> [SearchContent] {
        let parameters: [String: Any] = [
            "searchText": searchText,
            "isIncludeAdult": false,
            "searchMethod": "input",
            "page": 0,
            "size": 50,
            "isCheckDevice": false,
            "contentsThumbnailType": "VERTICAL,MAIN,SQUARE,VERTICAL_NOVELWRTIER,VERTICAL_NON_ADULT"
        ]
        
        let originalData = try await repository.search(parameters: parameters)
        
        guard let contents = originalData.data?.content else {
            throw NSError(domain: "SearchError", code: -1, userInfo: nil)
        }
        
        return contents
    }
    
    
    func executeFetchRecentKeywords() async throws -> [String] {
        return try await repository.fetch(limit: 20)
    }
    
    func executeSaveKeyword(keywordText: String) async {
        return await repository.save(keyword: keywordText)
    }
    
    func executeDeleteKeyword(keywordText: String) async {
        return await repository.delete(keyword: keywordText)
    }
    
    func executeDeleteAllKeyword() async throws {
        return await repository.deleteAll()
    }
    
}
