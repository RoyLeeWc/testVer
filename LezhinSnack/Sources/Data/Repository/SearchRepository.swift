//
//  SearchRepository.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/10/25.
//



protocol SearchRepositoryProtocol {
    func search(parameters: [String: Any]) async throws -> KRSearchDTO
    func save(keyword: String) async
    func fetch(limit: Int) async throws -> [String]
    func delete(keyword: String) async
    func deleteAll() async
    
}

class SearchRepository: SearchRepositoryProtocol {
    let service = RecentSearchService.shared
    
    func search(parameters: [String: Any]) async throws -> KRSearchDTO {
        let searchRequest = SearchAPIRequest(parameters: parameters)
        let searchResponse: KRSearchDTO = try await NetworkService.shared.requestAsync(searchRequest)
        
        
        return searchResponse
        
    }
    
    func save(keyword: String) async {
        await Task.detached(priority: .background) {
            self.service.saveKeyword(keyword)
        }.value
    }

    func fetch(limit: Int) async throws -> [String] {
        return try await Task.detached(priority: .background) {
            await self.service.fetchRecentKeywords(limit: limit)
        }.value
    }

    func delete(keyword: String) async {
        await Task.detached(priority: .background) {
            self.service.deleteKeyword(keyword)
        }.value
    }

    func deleteAll() async {
        await Task.detached(priority: .background) {
            self.service.clearAll()
        }.value
    }
    
}
