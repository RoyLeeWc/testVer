//
//  InAppPurchaseService.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/20/25.
//

import Alamofire
import Foundation
import StoreKit
import FirebaseAnalytics
import SwiftyUserDefaults
import Kronos

final class InAppPurchaseService {
    
    let requestPurchaseFinishStateManager = RequestStateManager()
    let requestPurchaseCheckStateManager = RequestStateManager()
    let requestPurchaseReadyStateManager = RequestStateManager()
    
    private let COMPLETE = "COMPLETE"
    
    var isPurchasing = false
    
    enum PurchaseApiEndpoint {
        /// 결제요청 API
        case paymentReady
        /// 코인충전 API
        case chargeStoreKit2
        /// 충전 실패 로그깅용 API
        case purchaseFailLog
        /// 충전여부 확인 API
        case paymentInquiry(tradeId: String)
        
        // 엔드포인트 경로를 반환하는 computed property
        var path: String {
            switch self {
            case .paymentReady:
                return "/v1/app/payment"
            case .chargeStoreKit2:
                return "/v2/app/ios/transaction"
            case .purchaseFailLog:
                return "/v1/app/ios/transaction/fail-log"
            case .paymentInquiry(let tradeId):
                return "/v1/app/\(tradeId)/inquiry"
            }
        }
        
        var flexURL: String {
            return AppContext.shared.flexApiUrl
        }
        
        var url: String {
            return flexURL + path
        }
    }
    
    static let shared = InAppPurchaseService()
    
    private init() {
        
    }
    
    func commonHeaders() -> HTTPHeaders{
        return AppContext.shared.commonHeader
    }
    
    func commonParam() -> [String: Any] {
        
        let bundleId = Bundle.main.bundleIdentifier
        let bundleVersion = AppContext.shared.getAppVersion()
        let deviceId = AppContext.shared.deviceUniqueID
        
        let param: [String: Any] = [
            "version": bundleVersion,
            "appId": bundleId ?? "",
            "deviceId": deviceId,
            "store": "apple"
        ]
        
        return param
    }
    
    func purchaseNewConsumableProduct(paymentInfo: PaymentInfoDTO) async throws -> InAppPurchaseEntity {
        
        if await isUnfinishedTransaction() {
            if isPurchasing {
                throw PurchaseError.alreadyRequestCoinCharge
            }
            
            self.isPurchasing = true
            defer { self.isPurchasing = false }
            return try await handleUnfinishedTransaction()
        }
        
        self.isPurchasing = true
        defer { self.isPurchasing = false }
        
        let tradeHistoryService = TradeHistoryService()
        let paymentReserveDTO = try await requestPurchaseReserve(data: paymentInfo)
        
        guard paymentReserveDTO.result == LZSConstant.ResponseSuccess,
              let reserveResultDTO = paymentReserveDTO.data,
              let userEmail = reserveResultDTO.userEmail,
              let productID = reserveResultDTO.productCode,
              let tradeId = reserveResultDTO.tradeId else {
            throw PurchaseError.invalidPayment
        }
         
        let products = try await Product.products(for: [productID])
        guard let product = products.first else { throw PurchaseError.invalidPayment }
        
        await tradeHistoryService.addMapping(productID: productID, tradeID: tradeId)
        
        let purchaseResult = try await product.purchase()
        
        
        switch purchaseResult {
            // 인앱결제 성공 및 영수증 검증 성공, 코인충전 요청
        case let .success(.verified(transaction)):
            let transactionId = String(transaction.id)
            let transactionEnvironment = getTransactionEnvironment(transaction)
            
            let paymentResultVO = try await requestPurchaseFinishV2(tradeId: tradeId, transactionId: transactionId,environment: transactionEnvironment)
            
            if paymentResultVO.result == LZSConstant.ResponseSuccess {
                
                await transaction.finish() //애플-결제성공, transaction API까지 호출 성공이므로 트랜잭션 종료처리
                await tradeHistoryService.removeMapping(productID: productID, tradeID: tradeId)
                
                Analytics.logTransaction(transaction)
                
                if let paymentResultData = paymentResultVO.data {
                    return InAppPurchaseEntity(inAppPurchaseType: .consumableCoin,
                                               amount: Int(paymentResultData.amount ?? 0),
                                               purchaseDate: transaction.purchaseDate,
                                               purchaseCoin: sumUpCoins([
                                                paymentResultData.chargeBonusCoin,
                                                paymentResultData.chargeCoin,
                                                paymentResultData.chargeFreeCoin
                                               ]),
                                               purchasePeriod: nil,
                                               paymentMethod: "충전소_결제수단_애플인앱".localized)
                }
                
            } else {
                printX("🚫 requestPurchaseFinish 요청 리스폰스 오류\n메시지: paymentResultVO is not Success ")
                
                let error = NSError(domain: "PurchaseStoreKit2", code: 0, userInfo: [
                    NSLocalizedDescriptionKey: "Payment result is not success."
                ])
                
                InAppPurchaseService.shared.requestPurchaseLog(userId: userEmail, tradeId: tradeId, receipt: error.localizedDescription)
                
                throw PurchaseError.networkResponseError(error)
                
            }
            // 구매를 성공했으나, verified 실패
        case let .success(.unverified(transaction, error)):
            InAppPurchaseService.shared.requestPurchaseLog(userId: userEmail, tradeId: tradeId, receipt: error.localizedDescription + String(transaction.id))
            throw PurchaseError.transactionVerificationFailed
            
        case .pending:
             Analytics.logEvent("inAppPurchase Pending", parameters: [:])
            throw PurchaseError.pending
            
        case .userCancelled:
            await tradeHistoryService.removeMapping(productID: productID, tradeID: tradeId)
            throw PurchaseError.userCancel
            
        @unknown default:
            throw PurchaseError.unknownError
        }
        throw PurchaseError.unknownError
    }
    
    
    private func sumUpCoins(_ coins: [Int?]) -> Int {
        return coins.compactMap { $0 }.reduce(0, +)
    }
    
    
    func processConsumableTransaction() async throws -> InAppPurchaseEntity? {
        if await isUnfinishedTransaction() {
            if isPurchasing {
                throw PurchaseError.alreadyRequestCoinCharge
            }
            
            self.isPurchasing = true
            defer { self.isPurchasing = false }
            return try await handleUnfinishedTransaction()
        }
        return nil
    }
    
    private func handleUnfinishedTransaction() async throws -> InAppPurchaseEntity {
        
        self.isPurchasing = true
        defer { self.isPurchasing = false }
        
        let tradeHistoryService = TradeHistoryService()
        
        for await result in Transaction.unfinished {
            let transaction = try self.checkVerified(result)
            let productID = transaction.productID
            
            guard let tradeId = await tradeHistoryService.getLatestTradeID(for: productID ) else {
                throw PurchaseError.invalidPayment
            }
            
            guard let resultEntity = try await requestCoinChargeWithLastPurchaseInfo(transaction: transaction, tradeId: tradeId) else { throw PurchaseError.invalidRedirectUrlString }
            
            return resultEntity
        }
        
        throw PurchaseError.invalidRedirectUrlString
    }
    
    private func requestCoinChargeWithLastPurchaseInfo( transaction: StoreKit.Transaction, tradeId: String ) async throws -> InAppPurchaseEntity? {
        
        let transactionEnvironment = getTransactionEnvironment(transaction)
        self.isPurchasing = true
        defer { self.isPurchasing = false }
        
        let transactionId = String(transaction.id)
        let tradeHistoryService = TradeHistoryService()
        
        let inquiryVO = try await self.requestPurchaseCheck(tradeId: tradeId)
        if inquiryVO.isSuccess() {
            if inquiryVO.data?.status == COMPLETE {
                if let inquiryTransactionId = inquiryVO.data?.transactionId,
                   inquiryTransactionId == transactionId {

                    Analytics.logTransaction(transaction)
                    await transaction.finish()
                    return nil
                } else {
                    let error = NSError(
                        domain: "PurchaseStoreKit2",
                        code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "inquiry result is not success."]
                    )
                    
                    return try await handlePurchaseError(
                        transaction: transaction,
                        tradeId: tradeId,
                        error: error
                    )
                }
            } else {
                let paymentDTO = try await requestPurchaseFinishV2(
                    tradeId: tradeId,
                    transactionId: transactionId,
                    environment: transactionEnvironment
                )
                if paymentDTO.isSuccess() {
                    await transaction.finish()
                    
                    // 매핑 삭제 및 데이터 정리
                    await tradeHistoryService.removeMapping(
                        productID: transaction.productID,
                        tradeID: tradeId
                    )
                    
                    Analytics.logTransaction(transaction)
                    
                    return InAppPurchaseEntity(inAppPurchaseType: .consumableCoin,
                                               amount: Int(paymentDTO.data?.amount ?? 0),
                                               purchaseDate: transaction.purchaseDate,
                                               purchaseCoin: sumUpCoins([
                                                paymentDTO.data?.chargeBonusCoin,
                                                paymentDTO.data?.chargeCoin,
                                                paymentDTO.data?.chargeFreeCoin
                                               ]),
                                               purchasePeriod: nil,
                                               paymentMethod: "충전소_결제수단_애플인앱".localized)
                    
                } else {
                    printX("🚫 requestPurchaseFinish 요청 리스폰스 오류\n메시지: paymentResultVO is not Success")
                    let error = NSError(
                        domain: "PurchaseStoreKit2",
                        code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "Payment result is not success."]
                    )
                    return try await handlePurchaseError(
                        transaction: transaction,
                        tradeId: tradeId,
                        error: error
                    )
                }
            }
        } else {
            printX("🚫 requestPurchaseCheck 요청 리스폰스 오류\n메시지: inquiryVO is not Success")
            let error = NSError(
                domain: "PurchaseStoreKit2",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "inquiry result is not success."]
            )
            return try await handlePurchaseError(
                transaction: transaction,
                tradeId: tradeId,
                error: error
            )
        }
    }
    
    private func handlePurchaseError( transaction: StoreKit.Transaction, tradeId: String, error: NSError ) async throws -> InAppPurchaseEntity? {
        let purchaseDate = transaction.purchaseDate

        if hasThirtyMinutesPassed(since: purchaseDate) {
            await transaction.finish()
            
        } else {
            
            let tradeHistoryService = TradeHistoryService()
            let transactionId = String(transaction.id)
            let productID = transaction.productID
            let tradeIDs = await tradeHistoryService.getTradeIDs(for: productID)

            if let retryResult = try await processTradeIDsInReverse (
                tradeIDs: tradeIDs,
                transaction: transaction ) {
                return retryResult
            } else {
                await transaction.finish()
                printX("로컬 디비까지 훑어도 실패 했습니다.", isBoxMode: true)
                let localError = NSError(
                    domain: "PurchaseStoreKit2",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "Fail Saved TradeIds:\(tradeIDs)"]
                )
                Analytics.logEvent("iOS_in_app_purchase_fail", parameters: ["tradeId": tradeId,
                                                                            "logType": "response",
                                                                            "transactionId": transactionId,
                                                                            "email": Defaults.userEmail,
                                                                            "error": "Fail Saved TradeIds:\(tradeIDs)"])
            }
        }
        throw PurchaseError.networkResponseError(error)
    }
    
    
    private func finalRequestCoinCharge(transaction: StoreKit.Transaction, tradeId: String) async throws -> InAppPurchaseEntity? {
        let transactionEnvironment = getTransactionEnvironment(transaction)
        let transactionId = String(transaction.id)
        let tradeHistoryService = TradeHistoryService()
        
        let inquiryVO = try await requestPurchaseCheck(tradeId: tradeId)
        if inquiryVO.isSuccess() {
            if inquiryVO.data?.status == COMPLETE {
                if let inquiryTransactionId = inquiryVO.data?.transactionId,
                   inquiryTransactionId == transactionId {
                    Analytics.logTransaction(transaction)
                    await transaction.finish()
                }
                return nil
            } else {
                let paymentDTO = try await requestPurchaseFinishV2(tradeId: tradeId, transactionId: transactionId,environment: transactionEnvironment)
                if (paymentDTO.isSuccess()) {
                    await transaction.finish() //애플-결제성공, transaction API까지 호출 성공이므로 트랜잭션 종료처리
                    await tradeHistoryService.removeMapping(productID: transactionId, tradeID: tradeId)
                    Analytics.logTransaction(transaction)
                    
                    return InAppPurchaseEntity(inAppPurchaseType: .consumableCoin,
                                               amount: Int(paymentDTO.data?.amount ?? 0),
                                               purchaseDate: transaction.purchaseDate,
                                               purchaseCoin: nil,
                                               purchasePeriod: nil,
                                               paymentMethod: "충전소_결제수단_애플인앱".localized)
                    
                } else {
                    // 트랜잭션의 구매 날짜 가져오기
                    let purchaseDate = transaction.purchaseDate
                    printX("🚫 requestPurchaseFinish 요청 리스폰스 오류\n메시지: paymentResultVO is not Success ")
                    // 30분이 지났는지 확인
                    if hasThirtyMinutesPassed(since: purchaseDate) {
                        await transaction.finish()
                    }
                    return nil
                }
            }
        } else {
            return nil
        }
    }
    
    
    private func processTradeIDsInReverse(
        tradeIDs: [String],
        transaction: StoreKit.Transaction ) async throws -> InAppPurchaseEntity? {
        // reversed()를 사용해 배열을 역순으로 순회합니다.
        let tradeHistoryService = TradeHistoryService()
            
        for tradeId in tradeIDs.reversed() {
            do {
                if let result = try await finalRequestCoinCharge( transaction: transaction, tradeId: tradeId ) {
                    // 성공적으로 URLRequest를 반환시
                    await tradeHistoryService.removeMapping(productID: transaction.productID, tradeID: tradeId)
                    return result
                } else {
                    await tradeHistoryService.removeMapping(productID: transaction.productID, tradeID: tradeId)
                    try await Task.sleep(nanoseconds: 3 * 1_000_000_000)
                }
            } catch {
                printX("tradeID: \(tradeId) 처리 중 에러 발생: \(error.localizedDescription)")
                // 에러 발생 시 해당 tradeId는 건너뛰고 다음 tradeId로 진행합니다.
            }
        }
        return nil
    }
    
    private func hasThirtyMinutesPassed(since purchaseDate: Date) -> Bool {
        let unixPurchaseTime = Int(purchaseDate.timeIntervalSince1970)
        var currentTime = Int(Date().timeIntervalSince1970)
        
        if let ntpCurrentTime = Clock.now {
            currentTime = Int(ntpCurrentTime.timeIntervalSince1970)
        }
        
        // 두 타임스탬프 간의 시간 차이 (초 단위)
        let timeDifference = currentTime - unixPurchaseTime
        
        // 30분(1800초)이 지났는지 여부 반환
        return timeDifference >= 1800
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.transactionVerificationFailed
        case .verified(let safe):
            return safe
        }
    }
    
    private func isUnfinishedTransaction() async -> Bool {
        for await _ in Transaction.unfinished {
            return true
        }
        return false
    }
    
    func getTransactionEnvironment(_ transaction: StoreKit.Transaction) -> String {
        if #available(iOS 16.0, *) {
            switch transaction.environment {
            case .production: return "PRODUCTION"
            case .sandbox: return "SANDBOX"
            case .xcode: return "SANDBOX"
            default:
                return "PRODUCTION"
            }
        } else {
            return "PRODUCTION"
        }
    }
}


/// API 호출 분리
extension InAppPurchaseService {

    /*
     MARK: 스토어킷2용, async 적용 리펙토리 함수
     
     1.requestPurchaseReserve : 인앱결제 예약
     2.requestPurchaseFinish : 인앱결제 종료
     3.requestPurchaseCheck : 충전확인 API
     */
    
    public func requestPurchaseReserve(data: PaymentInfoDTO) async throws -> PaymentReserveDTO {
        let header: HTTPHeaders = commonHeaders()
        var param = commonParam()
        
        // 요청 중인지 확인하고, 요청 중이면 에러를 반환
        let shouldProceed = await requestPurchaseReadyStateManager.shouldProceed()
        guard shouldProceed else {
            print("⚠️ 이미 requestPurchaseReady를 요청중입니다 ")
            throw PurchaseError.alreadyRequestCoinCharge
        }
        
        // 트랜잭션 함수 종료시에 다시 결제 요청 할수있게 플래그해제
        defer {
            Task { await requestPurchaseReadyStateManager.finishedRequest() }
        }
        
        param["paymentId"] = data.paymentId
        param["coinProductId"] = data.coinProductId
        param["episodeId"] = data.episodeId
        param["paymentMenu"] = data.paymentMenu
        param["redirectUrl"] = data.redirectUrl
        param["serviceId"] = data.serviceId
        param["accessToken"] = data.accessToken
        param["platform"] = data.platform
        param["ipAddress"] = AppContext.shared.deviceIPAddress
        
        let response = await AF.request(
            PurchaseApiEndpoint.paymentReady.url,
            method: .post,
            parameters: param,
            encoding: JSONEncoding.default,
            headers: header
        )
        .validate()
        .serializingDecodable(PaymentReserveDTO.self)
        .response
        
        switch response.result {
        case .success(let decodeData):
            printX("✅ requestPurchaseReserve 요청 성공")
            return decodeData
        case .failure(let error):
            printX("🚫 requestPurchaseReserve 요청 오류\n코드: \(error._code), 메시지: \(error.localizedDescription)")
            throw error
        }
    }


    public func requestPurchaseFinishV2(tradeId: String,transactionId: String,environment: String,maxRetries: Int = 3, retryDelay: TimeInterval = 1.0) async throws -> KRInAppPurchaseDTO {
        
        // 요청 중인지 확인하고, 요청 중이면 에러를 반환
        let shouldProceed = await requestPurchaseFinishStateManager.shouldProceed()
        guard shouldProceed else {
            printX("⚠️ 이미 requestPurchaseFinishV2를 요청중입니다 ")
            throw PurchaseError.alreadyRequestCoinCharge
        }
        
        // 트랜잭션 함수 종료시에 다시 결제 요청 할수있게 플래그해제
        defer {
            Task { await requestPurchaseFinishStateManager.finishedRequest() }
        }
        
        
        let header: HTTPHeaders = commonHeaders()
        var param = commonParam()
        
        param["tradeId"] = tradeId
        param["transactionId"] = transactionId
        param["environment"] = environment
        
        var attempt = 0
        
        while attempt < maxRetries {
            do {
                let response = await AF.request(
                    PurchaseApiEndpoint.chargeStoreKit2.url,
                    method: .post,
                    parameters: param,
                    encoding: JSONEncoding.default,
                    headers: header
                )
                .validate()
                .serializingDecodable(KRInAppPurchaseDTO.self)
                .response
                
                switch response.result {
                case .success(let decodeData):
                    printX("✅ requestPurchaseFinish 요청 성공")
                    return decodeData
                case .failure(let error):
                    // 에러가 타임아웃인지 확인
                    if let urlError = error.underlyingError as? URLError, urlError.code == .timedOut {
                        attempt += 1
                        printX("🚫 타임아웃 발생. 재시도 시도 \(attempt) / \(maxRetries)...")
                        
                        if attempt >= maxRetries {
                            printX("🚫 최대 재시도 횟수 도달. 타임아웃 에러 반환.")
                            throw PurchaseError.networkRequestError(error)
                        }
                        
                        // 재시도 전에 대기
                        try await Task.sleep(nanoseconds: UInt64(retryDelay * Double(NSEC_PER_SEC)))
                        
                    } else {
                        // 타임아웃이 아닌 다른 에러는 즉시 반환
                        printX("🚫 requestPurchaseFinish 요청 오류\n코드: \(error._code), 메시지: \(error.localizedDescription)")
                        throw PurchaseError.networkRequestError(error)
                    }
                }
            } catch {
//                // 예상치 못한 에러 처리 (예: 직렬화 문제)
//                printX("🚫 예상치 못한 에러: \(error.localizedDescription)")
//                throw PurchaseError.networkError(error)
            }
        }
        
        // 모든 재시도 실패 시 일반 타임아웃 에러 반환
        throw PurchaseError.networkRequestError(URLError(.timedOut))
    }
    
    
    //충전 확인 api
    public func requestPurchaseCheck(tradeId: String) async throws -> PurchaseInquiryDTO {
        
        
        // 충전 확인 api 요청 중인지 확인하고, 요청 중이면 에러를 반환
        let shouldProceed = await requestPurchaseCheckStateManager.shouldProceed()
        guard shouldProceed else {
            printX("⚠️ 이미 requestPurchaseCheck를 요청중입니다 ")
            throw PurchaseError.alreadyRequestCoinCharge
        }
        
        // 충전 확인 함수 종료시에 다시 결제 요청 할수있게 플래그해제
        defer {
            Task { await requestPurchaseCheckStateManager.finishedRequest() }
        }
        
        let header: HTTPHeaders = commonHeaders()
        let param = commonParam()
        let url: String = PurchaseApiEndpoint.paymentInquiry(tradeId: tradeId).url
        
        let response = await AF.request(url,
                   method: .get,
                   parameters: param,
                   encoding: URLEncoding.default,
                   headers: header)
        .validate()
        .responseString { result in
            printX(result)
        }
        .serializingDecodable(PurchaseInquiryDTO.self)
        .response
        
        switch response.result {
        case .success(let decodeData):
            printX("✅ requestPurchaseCheck 요청 성공")
            return decodeData
        case .failure(let error):
            printX("🚫 requestPurchaseFinish 요청 오류\n코드: \(error._code), 메시지: \(error.localizedDescription)")
            throw PurchaseError.networkRequestError(error)
        }
    }
    
    public func requestPurchaseLog(userId : String, tradeId : String, receipt : String){
        let header: HTTPHeaders = commonHeaders()
        var param = commonParam()
        param["userId"] = userId
        param["tradeId"] = tradeId
        param["receiptData"] = receipt
        
        AF.request(PurchaseApiEndpoint.purchaseFailLog.url as String, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header)
            .responseData{
                response in
                
                switch response.result {
                case .success:
                    print("get 성공")
                    
                case .failure(let error):
                    print("🚫 Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                }
            }
    }
    
}

actor RequestStateManager {
    private var isRequesting: Bool = false
    
    func shouldProceed() -> Bool {
        if isRequesting {
            return false
        }
        isRequesting = true
        return true
    }
    
    func finishedRequest() {
        isRequesting = false
    }
}
