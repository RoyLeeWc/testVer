//
//  InAppPurchaseService+Extension.swift
//  LezhinSnack
//
//  Created by 신진우 on 6/3/25.
//

import StoreKit
import Alamofire
import FirebaseAnalytics
import SwiftyUserDefaults

// InAppPurchaseService.swift 내 혹은 별도 파일에 추가
enum SubscriptionApiEndpoint {
    /// 구독 가입 준비 API
    case subscribeReady
    /// 구독 갱신/취소 등 서버 통보용 API
    case subscribeFinish
    /// 구독 상태 조회 API
    case subscriptionInquiry(tradeId: String)
    
    var path: String {
        switch self {
        case .subscribeReady:
            return "/v1/app/subscription/ready"
        case .subscribeFinish:
            return "/v1/app/subscription/finish"
        case .subscriptionInquiry(let tradeId):
            return "/v1/app/\(tradeId)/subscription/inquiry"
        }
    }
    
    var flexURL: String {
        return AppContext.shared.flexApiUrl
    }
    
    var url: String {
        return flexURL + path
    }
}

extension InAppPurchaseService {

    func processSubscriptionTransaction(_ transaction: Transaction) async {
        // 1) 검증된 트랜잭션이므로, 서버에 구독 갱신/취소/만료 이벤트 통보
        let tradeHistoryService = TradeHistoryService()
        let productID = transaction.productID
        
        // 2) 서버에 등록된 tradeId 조회
        guard let tradeId = await tradeHistoryService.getLatestTradeID(for: productID) else {
            // 매핑이 없으면 별도 처리 (예: 서버 내부 DB 동기화 문제 등)
            return
        }
        
        // 3) 서버 쪽에서 “구독 상태 확인” API 호출
        do {
            let inquiryDTO = try await requestSubscriptionInquiry(tradeId: tradeId)
            
            if inquiryDTO.result == LZSConstant.ResponseSuccess,
               let inqData = inquiryDTO.data {
                // ACTIVE 상태면 “갱신됨”
                if inqData.status == "ACTIVE" {
                    print("✅ 구독 갱신됨: \(productID) 만료일: \(Date(timeIntervalSince1970: Double(inqData.expirationDate ?? 0)))")
                }
                // CANCELLED 상태면 “취소됨”
                else if inqData.status == "CANCELLED" {
                    print("⚠️ 구독 취소됨: \(productID)")
                }
                // EXPIRED 상태면 “만료됨”
                else if inqData.status == "EXPIRED" {
                    print("⏱ 구독 만료됨: \(productID)")
                }
            }
            
            // 마지막으로 finish()
            await transaction.finish()
        } catch {
            print("구독 업데이트 처리 실패: \(error.localizedDescription)")
            // 오류 시에도 Transaction.finish() 처리 (필요 시)
            await transaction.finish()
        }
    }

    // MARK: - 4) 구독형 상품 구매 처리
    /// paymentInfo 내에 subscriptionProductId, userId, platform 등이 담겨 있다고 가정
    func purchaseNewSubscription(paymentInfo: PaymentInfoDTO) async throws -> InAppPurchaseEntity {
        // 1️⃣ 이미 미완료된 구독 트랜잭션이 있는지 확인
        if await isUnfinishedSubscriptionTransaction() {
            if isPurchasing {
                throw PurchaseError.alreadyRequestSubscription
            }
            self.isPurchasing = true
            defer { self.isPurchasing = false }
            return try await handleUnfinishedSubscription()
        }
        
        // 2️⃣ 중복 구매 방지 상태 플래그
        self.isPurchasing = true
        defer { self.isPurchasing = false }
        
        let tradeHistoryService = TradeHistoryService()
        
        // 3️⃣ 서버에 “구독 준비(reserve)” 요청
        let subscriptionReserveDTO = try await requestSubscriptionReserve(data: paymentInfo)
        
        guard subscriptionReserveDTO.result == LZSConstant.ResponseSuccess,
              let reserveData = subscriptionReserveDTO.data,
              let userEmail = reserveData.userEmail,
              let productID = reserveData.productCode,
              let tradeId = reserveData.tradeId else {
            throw PurchaseError.invalidSubscription
        }
        
        // 4️⃣ StoreKit 2: 해당 구독 상품 Product 객체 가져오기
        let products = try await Product.products(for: [productID])
        guard let product = products.first else {
            throw PurchaseError.invalidSubscription
        }
        
        // 5️⃣ 서버-로컬 매핑 (Trade ID 매핑)
        await tradeHistoryService.addMapping(productID: productID, tradeID: tradeId)
        
        // 6️⃣ 실제 StoreKit 2 결제 호출
        let purchaseResult = try await product.purchase()
        
        switch purchaseResult {
        case let .success(.verified(transaction)):
            // 7️⃣ 구독 성공 후 서버에 “구독 가입 완료” 통보
            let transactionId = String(transaction.id)
            let transactionEnvironment = getTransactionEnvironment(transaction)
            
            let subscriptionFinishDTO = try await requestSubscriptionFinish(
                tradeId: tradeId,
                transactionId: transactionId,
                environment: transactionEnvironment
            )
            
            if subscriptionFinishDTO.result == LZSConstant.ResponseSuccess {
                // 8️⃣ StoreKit 트랜잭션 종료 & 매핑 삭제
                await transaction.finish()
                await tradeHistoryService.removeMapping(
                    productID: productID,
                    tradeID: tradeId
                )
                
                Analytics.logTransaction(transaction)
                
                // 9️⃣ 앱 내부 엔티티 반환 (구독은 기간 개념이므로 purchasePeriod를 사용)
                if let finishData = subscriptionFinishDTO.data {
                    let purchaseDate = transaction.purchaseDate
                    let expirationDate = transaction.expirationDate
                    
                    return InAppPurchaseEntity(
                        inAppPurchaseType: .annual,
                        amount: 0,                            // 금액은 서버에서 계산; 필요 시 DTO에 포함
                        purchaseDate: purchaseDate,
                        purchaseCoin: nil,                    // 구독은 코인이 아님
                        purchasePeriod: expirationDate?.toStringWithGMT(regionCode: LZSUtil.getCurrentRegionCode()),       // 만료일자를 전달
                        paymentMethod: "구독_결제수단_애플인앱".localized
                    )
                }
            } else {
                // 서버 응답 실패 시 로그
                let error = NSError(domain: "PurchaseStoreKit2", code: 0, userInfo: [
                    NSLocalizedDescriptionKey: "Subscription finish is not success."
                ])
                InAppPurchaseService.shared.requestSubscriptionLog(
                    userId: userEmail,
                    tradeId: tradeId,
                    receipt: error.localizedDescription
                )
                throw PurchaseError.networkResponseError(error)
            }
            
        case let .success(.unverified(transaction, error)):
            // 거래 검증 실패 시 로그
            InAppPurchaseService.shared.requestSubscriptionLog(
                userId: Defaults.userId,
                tradeId: tradeId,
                receipt: error.localizedDescription + String(transaction.id)
            )
            throw PurchaseError.transactionVerificationFailed
            
        case .pending:
            Analytics.logEvent("subscription Pending", parameters: [:])
            throw PurchaseError.pending
            
        case .userCancelled:
            // 사용자가 구독 결제 화면을 취소
            await tradeHistoryService.removeMapping(
                productID: reserveData.productCode ?? "",
                tradeID: tradeId
            )
            throw PurchaseError.userCancel
            
        @unknown default:
            throw PurchaseError.unknownError
        }
        
        throw PurchaseError.unknownError
    }

    // MARK: - 5) 미완료된 구독 트랜잭션 처리
    private func isUnfinishedSubscriptionTransaction() async -> Bool {
        for await _ in Transaction.unfinished {
            return true
        }
        return false
    }
    
    private func handleUnfinishedSubscription() async throws -> InAppPurchaseEntity {
        // 소모성과 유사하게, Transaction.unfinished을 순회
        let tradeHistoryService = TradeHistoryService()
        
        for await result in Transaction.unfinished {
            // 1) 검증
            let transaction = try checkVerified(result)
            let productID = transaction.productID
            
            // 2) 서버에서 tradeId 조회
            guard let tradeId = await tradeHistoryService.getLatestTradeID(for: productID) else {
                throw PurchaseError.invalidSubscription
            }
            
            // 3) 서버에 “구독 상태 확인” 호출
            let inquiryDTO = try await requestSubscriptionInquiry(tradeId: tradeId)
            if inquiryDTO.result == LZSConstant.ResponseSuccess,
               let inqData = inquiryDTO.data {
                // 4) 만료 전인지, 실제 활성 구독인지 판단
                if inqData.status == "ACTIVE" {
                    // 이미 활성화된 구독인 경우, 트랜잭션만 종료
                    await transaction.finish()
                    return InAppPurchaseEntity(
                        inAppPurchaseType: .monthly,
                        amount: 0,
                        purchaseDate: transaction.purchaseDate,
                        purchaseCoin: nil,
                        purchasePeriod: transaction.expirationDate?.toStringWithGMT(regionCode: LZSUtil.getCurrentRegionCode()),
                        paymentMethod: "구독_결제수단_애플인앱".localized
                    )
                } else {
                    // ACTIVE가 아니라면: 서버에서 갱신/취소가 필요 → finish 후 에러 던짐
                    await transaction.finish()
                    throw PurchaseError.subscriptionNotActive
                }
            } else {
                await transaction.finish()
                throw PurchaseError.invalidSubscription
            }
        }
        throw PurchaseError.invalidSubscription
    }
    
    // MARK: - 6) 구독 전용 서버 호출 함수들
    func requestSubscriptionReserve(data: PaymentInfoDTO) async throws -> SubscriptionReserveDTO {
        let header: HTTPHeaders = commonHeaders()
        var param = commonParam()
        
        let shouldProceed = await requestPurchaseReadyStateManager.shouldProceed()
        guard shouldProceed else {
            throw PurchaseError.alreadyRequestSubscription
        }
        defer { Task { await requestPurchaseReadyStateManager.finishedRequest() } }
        
        param["subscriptionProductId"] = data.coinProductId
        param["accessToken"] = data.accessToken
        param["platform"] = data.platform
        
        let response = await AF.request(
            SubscriptionApiEndpoint.subscribeReady.url,
            method: .post,
            parameters: param,
            encoding: JSONEncoding.default,
            headers: header
        )
        .validate()
        .serializingDecodable(SubscriptionReserveDTO.self)
        .response
        
        switch response.result {
        case .success(let decodeData):
            return decodeData
        case .failure(let error):
            throw error
        }
    }
    
    func requestSubscriptionFinish(
        tradeId: String,
        transactionId: String,
        environment: String
    ) async throws -> SubscriptionFinishDTO {
        let header: HTTPHeaders = commonHeaders()
        var param = commonParam()
        
        let shouldProceed = await requestPurchaseFinishStateManager.shouldProceed()
        guard shouldProceed else {
            throw PurchaseError.alreadyRequestSubscription
        }
        defer { Task { await requestPurchaseFinishStateManager.finishedRequest() } }
        
        param["tradeId"] = tradeId
        param["transactionId"] = transactionId
        param["environment"] = environment
        
        let response = await AF.request(
            SubscriptionApiEndpoint.subscribeFinish.url,
            method: .post,
            parameters: param,
            encoding: JSONEncoding.default,
            headers: header
        )
        .validate()
        .serializingDecodable(SubscriptionFinishDTO.self)
        .response
        
        switch response.result {
        case .success(let decodeData):
            return decodeData
        case .failure(let error):
            throw PurchaseError.networkRequestError(error)
        }
    }
    
    func requestSubscriptionInquiry(tradeId: String) async throws -> SubscriptionInquiryDTO {
        let header: HTTPHeaders = commonHeaders()
        let param = commonParam()
        let url: String = SubscriptionApiEndpoint.subscriptionInquiry(tradeId: tradeId).url
        
        let response = await AF.request(
            url,
            method: .get,
            parameters: param,
            encoding: URLEncoding.default,
            headers: header
        )
        .validate()
        .serializingDecodable(SubscriptionInquiryDTO.self)
        .response
        
        switch response.result {
        case .success(let decodeData):
            return decodeData
        case .failure(let error):
            throw PurchaseError.networkRequestError(error)
        }
    }
    
    func requestSubscriptionLog(userId: String, tradeId: String, receipt: String) {
        let header: HTTPHeaders = commonHeaders()
        var param = commonParam()
        param["userId"] = userId
        param["tradeId"] = tradeId
        param["receiptData"] = receipt
        
        AF.request( "",
            method: .post,
            parameters: param,
            encoding: JSONEncoding.default,
            headers: header
        )
        .responseData { response in
            switch response.result {
            case .success:
                print("✅ 구독 로그 전송 성공")
            case .failure(let error):
                print("🚫 구독 로그 전송 실패: \(error.localizedDescription)")
            }
        }
    }
}
