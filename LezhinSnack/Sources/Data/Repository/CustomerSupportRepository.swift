//
//  CustomerSupportRepository.swift
//  LezhinSnack
//
//  Created by lwc on 10/17/25.
//

import Foundation

protocol CustomerSupportRepositoryProtocol {
    
    func fetchNotice(id: String) async throws -> NoticeEntity?
    
    func fetchNoticeList() async throws -> [NoticeListEntity]
    
    func fetchFaqCategories() async throws -> [FaqCategoryEntity]
        
    func fetchFaqList() async throws -> [FaqEntity]
        
    func fetchFaqDetail(faqId: Int) async throws -> FaqDetailEntity?
    
}

enum CustomerSupportRepositoryError: Error {
    case api(code: String, message: String)
    case invalidData
}

final class CustomerSupportRepository: CustomerSupportRepositoryProtocol {
    
    func fetchNotice(id: String) async throws -> NoticeEntity? {
        
        let req = NoticeAPIRequest(noiceId: id)
        let dto: NoticeDTO = try await NetworkService.shared.requestAsync(req)
        
        guard dto.responseCode == "SUCCESS" else {
            let msg = dto.errorData?.defaultMessage ?? "실패"
            throw CustomerSupportRepositoryError.api(code: dto.errorData?.code ?? "ERROR", message: msg)
        }
        
        guard let dto = dto.data else { return nil }
        return dto.toEntity()
    }

    func fetchNoticeList() async throws -> [NoticeListEntity] {
        
        let req = NoticeListAPIRequest()
        let dto: NoticeListDTO = try await NetworkService.shared.requestAsync(req)
        
        guard dto.responseCode == "SUCCESS" else {
            let msg = dto.errorData?.defaultMessage ?? "실패"
            throw CustomerSupportRepositoryError.api(code: dto.errorData?.code ?? "ERROR", message: msg)
        }

        
        return (dto.data ?? []).map { $0.toEntity() }
    }
    
    func fetchFaqCategories() async throws -> [FaqCategoryEntity] {
        let req = FaqCategoryAPIRequest()
        let dto: FaqCategoryListDTO = try await NetworkService.shared.requestAsync(req)
        
        guard dto.responseCode == "SUCCESS" else {
            let msg = dto.errorData?.defaultMessage ?? "실패"
            throw CustomerSupportRepositoryError.api(code: dto.errorData?.code ?? "ERROR", message: msg)
        }
        return (dto.data ?? []).map { $0.toEntity() }
    }
    
    func fetchFaqList() async throws -> [FaqEntity] {
        let req = FaqListAPIRequest()
        let dto: FaqListDTO = try await NetworkService.shared.requestAsync(req)
        
        guard dto.responseCode == "SUCCESS" else {
            let msg = dto.errorData?.defaultMessage ?? "실패"
            throw CustomerSupportRepositoryError.api(code: dto.errorData?.code ?? "ERROR", message: msg)
        }
        return (dto.data ?? []).map { $0.toEntity() }
    }
    
    func fetchFaqDetail(faqId: Int) async throws -> FaqDetailEntity? {
        let req = FaqDetailAPIRequest(faqId: faqId)
        let dto: FaqDetailDTO = try await NetworkService.shared.requestAsync(req)
        
        guard dto.responseCode == "SUCCESS" else {
            let msg = dto.errorData?.defaultMessage ?? "실패"
            throw CustomerSupportRepositoryError.api(code: dto.errorData?.code ?? "ERROR", message: msg)
        }
        return dto.data?.toEntity()
    }
}
