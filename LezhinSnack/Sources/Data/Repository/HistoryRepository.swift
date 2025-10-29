//
//  HistoryRepository.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/12/25.
//

import Foundation



protocol HistoryRepositoryProtocol {
    func fetchCoinCharges(page: Int, size: Int, filter: CoinChargeFilter) async throws -> PagedEntity<CoinChargeEntity>
    func fetchCoinUsage(page: Int, size: Int) async throws -> PagedEntity<CoinUsageEntity>
    func fetchUserPayments(page: Int, size: Int) async throws -> PagedEntity<PaymentHistoryEntity>
    func fetchPaymentDetail(transactionId: String) async throws -> PaymentDetailEntity
    
    func purchaseHistory(parameters: [String: Any]) async throws -> [PurchaseHistoryEntity]
    func coinChargeHistory(parameters: [String: Any]) async throws -> [CoinChargeHistoryEntity]
    
}

enum HistoryRepositoryError: Error {
    case api(code: String, message: String)
    case invalidData
}

class HistoryRepository: HistoryRepositoryProtocol {
    
    func fetchCoinCharges(page: Int, size: Int, filter: CoinChargeFilter) async throws -> PagedEntity<CoinChargeEntity> {
        let req = MyCoinChargesAPIRequest(page: page, size: size, filter: filter)
        let dto: MyCoinChargesDTO = try await NetworkService.shared.requestAsync(req)
        
        guard dto.responseCode == "SUCCESS", let data = dto.data else {
            let msg = dto.errorData?.defaultMessage ?? "코인 충전내역 조회 실패"
            throw HistoryRepositoryError.api(code: dto.errorData?.code ?? "ERROR", message: msg)
        }
        return data.toEntity()
    }
    
    func fetchCoinUsage(page: Int, size: Int) async throws -> PagedEntity<CoinUsageEntity> {
        let req = CoinUsageHistoryAPIRequest(page: page, size: size)
        let dto: CoinUsageHistoryDTO = try await NetworkService.shared.requestAsync(req)
        
        guard dto.responseCode == "SUCCESS", let data = dto.data else {
            let msg = dto.errorData?.defaultMessage ?? "코인 사용내역 조회 실패"
            throw HistoryRepositoryError.api(code: dto.errorData?.code ?? "ERROR", message: msg)
        }
        return data.toEntity()
    }
    
    func fetchUserPayments(page: Int, size: Int) async throws -> PagedEntity<PaymentHistoryEntity> {
        let req = UserPaymentHistoryAPIRequest(page: page, size: size)
        let dto: PaymentHistoriesDTO = try await NetworkService.shared.requestAsync(req)
        guard dto.responseCode == "SUCCESS", let data = dto.data else {
            let code = dto.errorData?.code ?? "ERROR"
            let msg  = dto.errorData?.defaultMessage ?? "Fetch user payments failed."
            throw HistoryRepositoryError.api(code: code, message: msg)
        }
        return data.toEntity()
    }
    
    func fetchPaymentDetail(transactionId: String) async throws -> PaymentDetailEntity {
        let req = PaymentDetailAPIRequest(transactionId: transactionId)
        let dto: PaymentDetailDTO = try await NetworkService.shared.requestAsync(req)
        guard dto.responseCode == "SUCCESS", let data = dto.data else {
            let code = dto.errorData?.code ?? "ERROR"
            let msg  = dto.errorData?.defaultMessage ?? "Fetch payment detail failed."
            throw HistoryRepositoryError.api(code: code, message: msg)
        }
        return data.toEntity()
    }
    
///-----------------------------------------
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
