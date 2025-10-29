//
//  AppVersionRepository.swift
//  LezhinSnack
//
//  Created by lwc on 9/4/25.
//
import Foundation


protocol AppVersionRepositoryProtocol {
    func check(parameters: [String: Any]) async throws -> AppVerCheckDTO
}

final class AppVersionRepository: AppVersionRepositoryProtocol {
    
    func check(parameters: [String: Any]) async throws -> AppVerCheckDTO {
        let req = AppVersionsCheckAPIRequest(parameters: parameters)
        // responseCode, data를 DTO로 받아서 상위(UseCase)에서 정책 처리
        
        let dto: AppVerCheckDTO = try await NetworkService.shared.requestAsync(req)
        return dto
    }
}
