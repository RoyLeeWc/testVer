//
//  HistoryRepository.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/12/25.
//

import Foundation



protocol HistoryRepositoryProtocol {
    func purchaseHistory(parameters: [String: Any]) async throws -> [PurchaseHistoryEntity]
    func coinChargeHistory(parameters: [String: Any]) async throws -> [CoinChargeHistoryEntity]
}


class HistoryRepository: HistoryRepositoryProtocol {
    
    func purchaseHistory(parameters: [String: Any]) async throws -> [PurchaseHistoryEntity] {
        
        let purchaseHistoryRequest = PurchaseHistoryAPIRequest(parameters: parameters)
        let purchaseHistoryResponse: KRPurchaseHistoryDTO = try await NetworkService.shared.requestAsync(purchaseHistoryRequest)
        
        guard purchaseHistoryResponse.result == LZSConstant.ResponseSuccess,
              let data = purchaseHistoryResponse.data else {
            throw NSError(
                domain: "HistoryError",
                code: -1,
                userInfo: nil
            )
        }
        
        return data.compactMap { purchasedItem in
            guard let title = purchasedItem.title else { return nil }
            return PurchaseHistoryEntity(title: title)
        }
        
    }
    
    func coinChargeHistory(parameters: [String: Any]) async throws -> [CoinChargeHistoryEntity] {
        
        let coinChargeHistoryAPIRequest = CoinChargeHistoryAPIRequest(parameters: parameters)
        let coinChargeHistoryResponse: KRCoinChargeHistoryDTO = try await NetworkService.shared.requestAsync(coinChargeHistoryAPIRequest)
        
        guard coinChargeHistoryResponse.result == LZSConstant.ResponseSuccess,
              let data = coinChargeHistoryResponse.data else {
            throw NSError(
                domain: "HistoryError",
                code: -1,
                userInfo: nil
            )
        }
        
        return data.compactMap { coinChargeItem in
            guard let title = coinChargeItem.title else { return nil }
            return CoinChargeHistoryEntity(title: title)
        }
    }
    
}
