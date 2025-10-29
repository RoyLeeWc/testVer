//
//  SubscriptionRepository.swift
//  LezhinSnack
//
//  Created by lwc on 10/1/25.
//

import Foundation

protocol SubscriptionRepositoryProtocol {
    func fetchMySubscription() async throws -> MySubscriptionInfoEntity?
}

enum SubscriptionRepositoryError: Error {
    case api(code: String, message: String)
    case invalidData
}


final class SubscriptionRepository: SubscriptionRepositoryProtocol {
    
    func fetchMySubscription() async throws -> MySubscriptionInfoEntity? {
        
        let req = MySubscriptionAPIRequest()
        let dto: MySubscriptionDTO = try await NetworkService.shared.requestAsync(req)
        
        guard dto.responseCode == "SUCCESS" else {
            let msg = dto.errorData?.defaultMessage ?? "구독 조회 실패"
            throw SubscriptionRepositoryError.api(code: dto.errorData?.code ?? "ERROR", message: msg)
        }
        
        // 미구독자: data == null → nil 반환
        guard let dto = dto.data else { return nil }
        return dto.toEntity()
    }
    
}
