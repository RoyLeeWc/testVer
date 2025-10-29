//
//  HistoryUserCase.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/12/25.
//

import Foundation

protocol HistoryUseCaseProtocol {
    func executePurchaseHistory() async throws -> [PurchaseHistoryEntity]
    func executeCoinChargeHistory() async throws -> [CoinChargeHistoryEntity]
}

class HistoryUseCase: HistoryUseCaseProtocol {
    
    private let repository: HistoryRepositoryProtocol
    
    init(historyRepository: HistoryRepositoryProtocol) {
        self.repository = historyRepository
    }
    
    func executePurchaseHistory() async throws -> [PurchaseHistoryEntity] {
        
        let dateTime = LZSUtil.getCurrentTimeDate()
        var unixTime = LZSUtil.getCurrentTimeUnixInt64()
        
        if let date90DaysAgo = Calendar.current.date(byAdding: .day, value: -90, to: dateTime) {
            unixTime = Int64(date90DaysAgo.timeIntervalSince1970)
        } else {
            unixTime -= ( 90 * 24 * 60 * 60 )
        }
        
        
        let parameters: [String: Any] = [
            "createdAt": unixTime
        ]
        
        let originalData = try await repository.purchaseHistory(parameters: parameters)
        
        return originalData
        
    }
    
    func executeCoinChargeHistory() async throws -> [CoinChargeHistoryEntity] {
        
        let dateTime = LZSUtil.getCurrentTimeDate()
        var unixTime = LZSUtil.getCurrentTimeUnixInt64()
        
        if let date90DaysAgo = Calendar.current.date(byAdding: .day, value: -90, to: dateTime) {
            unixTime = Int64(date90DaysAgo.timeIntervalSince1970)
        } else {
            unixTime -= ( 90 * 24 * 60 * 60 )
        }
        
        
        let parameters: [String: Any] = [
            "createdAt": unixTime
        ]
        
        let originalData = try await repository.coinChargeHistory(parameters: parameters)
        
        return originalData
        
    }
    
}
