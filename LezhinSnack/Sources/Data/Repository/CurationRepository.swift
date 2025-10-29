//
//  HomeRepository.swift
//  LezhinSnack
//
//  Created by lwc on 9/10/25.
//

protocol CurationRepositoryProtocol {
    func fetchCurationList() async throws -> [CurationItemDTO]
    
    func fetchRanking(period: String, topN: Int, type: String) async throws -> [ContentsRankingItemDTO]
    func fetchContentsBanners(curationId: String) async throws -> [ContentsBannerItemDTO]
    func fetchContentsOngoing() async throws -> [ContentsOngoingItemDTO]
    func fetchContentsLastWatch() async throws -> [ContentsLastWatcItemDTO]
    func fetchContentsCuration(curationId: String) async throws -> [ContentsCurationItemDTO]
    
}

enum CurationRepositoryError: Error {
    case api(code: String, message: String)
}

final class CurationRepository: CurationRepositoryProtocol {
    
    func fetchCurationList() async throws -> [CurationItemDTO] {
        let req = CurationListAPIRequest()
        let dto: CurationListDTO = try await NetworkService.shared.requestAsync(req)
        guard dto.responseCode == "SUCCESS" else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "Curation fetch failed"
            throw CurationRepositoryError.api(code: code, message: msg)
        }
        return dto.data
    }
    
    func fetchRanking(period: String, topN: Int, type: String) async throws -> [ContentsRankingItemDTO] {
        let req = ContentsRankingAPIRequest(period: period, topN: topN, type: type)
        let dto: ContentsRankingDTO = try await NetworkService.shared.requestAsync(req)
        guard dto.responseCode == "SUCCESS" else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "Ranking fetch failed"
            throw CurationRepositoryError.api(code: code, message: msg)
        }
        return dto.data
    }
    
    func fetchContentsBanners(curationId: String) async throws -> [ContentsBannerItemDTO] {
        let req = ContentsBannerAPIRequest(curationId: curationId)
        let dto: ContentsBannerDTO = try await NetworkService.shared.requestAsync(req)
        guard dto.responseCode == "SUCCESS" else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "Ranking fetch failed"
            throw CurationRepositoryError.api(code: code, message: msg)
        }
        return dto.data
    }
    
    func fetchContentsOngoing() async throws -> [ContentsOngoingItemDTO] {
        let req = ContentsOngoingAPIRequest()
        let dto: ContentsOngoingDTO = try await NetworkService.shared.requestAsync(req)
        guard dto.responseCode == "SUCCESS" else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "Ranking fetch failed"
            throw CurationRepositoryError.api(code: code, message: msg)
        }
        return dto.data
    }
    
    func fetchContentsLastWatch() async throws -> [ContentsLastWatcItemDTO] {
        let req = ContentsLastWatchAPIRequest()
        let dto: ContentsLastWatchDTO = try await NetworkService.shared.requestAsync(req)
        guard dto.responseCode == "SUCCESS" else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "Ranking fetch failed"
            throw CurationRepositoryError.api(code: code, message: msg)
        }
        return dto.data
    }
    
    func fetchContentsCuration(curationId: String) async throws -> [ContentsCurationItemDTO] {
        let req = ContentsCurationContentsAPIRequest(curationId: curationId)
        let dto: ContentsCurationDTO = try await NetworkService.shared.requestAsync(req)
        guard dto.responseCode == "SUCCESS" else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "Ranking fetch failed"
            throw CurationRepositoryError.api(code: code, message: msg)
        }
        return dto.data
    }
    
    
    
}
