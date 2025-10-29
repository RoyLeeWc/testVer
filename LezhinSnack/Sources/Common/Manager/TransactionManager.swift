//
//  TransactionManager.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/2/25.
//

import StoreKit

final class TransactionManager {
    
    
    static let shared = TransactionManager()
    
    private init() {
        
    }
    
    
    private var transactionListenerTask: Task<Void, Never>?
    
    /// 앱 시작 시점 또는 원하는 시점에 한 번 호출하여 리스너를 등록합니다.
    func startTransactionListener() {
        // 이미 등록된 상태라면 중복 등록 방지
        guard transactionListenerTask == nil else { return }
        
        transactionListenerTask = Task.detached { [weak self] in
            // Transaction.updates: StoreKit에서 진행된 모든 트랜잭션 흐름을 비동기로 스트림 형태로 전달
            guard let self = self else { return }
            for await result in Transaction.updates {
                do {
                    let verifiedTransaction = try self.checkVerified(result)
                    // 트랜잭션 처리 - 메인 스레드에서 실행
                    if let revocationReason = verifiedTransaction.revocationReason, let revocationDate = verifiedTransaction.revocationDate {
                        print("트랜잭션 환불 감지: \(verifiedTransaction)")
                        print("트랜잭션 환불 사유: \(revocationReason)")
                        print("트랜잭션 환불 시각: \(revocationDate)")
                        await verifiedTransaction.finish()
                    } else {
                        try await processTransaction(verifiedTransaction)
                    }
                } catch {
                    // 에러 처리
                    print("트랜잭션 검증 실패: \(error)")
                }
            }
        }
    }
    
    func checkForUnfinishedTransactions() {
        LZSnackConcurrencyManager.run {  [weak self] in
            guard let self = self else { return }
            for try await transaction in Transaction.unfinished {
                let verifiedTransaction = try self.checkVerified(transaction)
                if let revocationReason = verifiedTransaction.revocationReason, let revocationDate = verifiedTransaction.revocationDate {
                    print("트랜잭션 환불 감지: \(verifiedTransaction)")
                    await verifiedTransaction.finish()
                } else {
                    try await processTransaction(verifiedTransaction)
                }
            }
        }
    }
    
    
    private func processTransaction(_ transaction: Transaction) async throws {
        switch transaction.productType {
        case .consumable:
            if InAppPurchaseService.shared.isPurchasing == false {
                try await InAppPurchaseService.shared.processConsumableTransaction()
            }
        case .autoRenewable:
//            if InAppPurchaseService.shared.isPurchasing == false {
//                await InAppPurchaseService.shared.processSubscriptionTransaction(transaction)
//            }
            
            try await processSubscriptionTransaction(transaction)
            
            await transaction.finish()
        default: break
        }
    }
    
    /// 자동 갱신 구독 트랜잭션을 처리하는 메서드
    ///
    /// 1) expirationDate를 확인하여 이미 만료되었는지 확인
    /// 2) 만료되지 않았다면 활성/갱신 이벤트로 간주하고, 필요한 권한 부여 및 동기화
    /// 3) 모든 처리 후 finish()를 호출하여 StoreKit이 트랜잭션을 보류하지 않도록 함
    private func processSubscriptionTransaction(_ transaction: Transaction) async {
        // 1) 트랜잭션 객체에서 만료일(expirationDate)을 반드시 확인
        //    expirationDate는 UTC 기준 UNIX timestamp로 제공됩니다.
        guard let expiryDate = transaction.expirationDate else {
            // 만료일 정보가 없으면 바로 finish()만 호출
            await transaction.finish()
            return
        }
        
        // 2) 만료 여부 판단: 현재 시각이 만료일 이후라면 이미 만료된 상태
        if expiryDate < LZSUtil.getCurrentTimeDate() {
            // 만료된 상태: 사용자가 관리 화면에서 해지했거나 기간 종료
            print("⏱ 구독 만료 감지:")
            print("    • productID: \(transaction.productID)")
            print("    • transactionID: \(transaction.id)")
            print("    • 만료일: \(expiryDate)")
            
            // 만료된 구독을 서버 또는 로컬에 동기화하여 사용자의 권한을 해제
            // 예: SubscriptionService.shared.handleExpiration(for: transaction)
            
            // 3) 만료 처리 후 반드시 finish() 호출
            await transaction.finish()
            
        } else {
            // 아직 만료되지 않은 상태: 신규 구매 혹은 갱신 이벤트
            print("✅ 구독 활성/갱신 감지:")
            print("    • productID: \(transaction.productID)")
            print("    • transactionID: \(transaction.id)")
            print("    • 만료일: \(expiryDate)")
            
            // *** iOS 15에서는 Transaction에 renewalInfo 프로퍼티가 제공되지 않으므로 ***
            // *** 해지 예약 여부(auto renew off) 정보를 확인할 수 없습니다.      ***
            // *** 만약 해지 예약 상태를 표시해야 한다면, iOS 16 이상을 타겟팅하거나, ***
            // *** 서버 사이드 영수증 검증을 통해 예약 여부를 판단해야 합니다.      ***

            // 유효 구독인 경우 유료 기능 권한을 활성화하고, 서버 동기화를 수행
            // 예: SubscriptionService.shared.syncSubscription(transaction)
            
            // 4) 활성 상태 처리 후 finish() 호출
            await transaction.finish()
        }
    }
    
    // MARK: - 4. 현재 활성 구독(Entitlements) 가져오기
    
    /// 기기에 남아 있는 만료되지 않은 자동 갱신 구독 트랜잭션을 배열로 반환합니다.
    /// 앱이 활성화될 때마다 호출하여 현재 사용자의 구독 상태를 갱신할 때 사용합니다.
    ///
    /// - 중요:
    ///   1) Transaction.currentEntitlements는 기기에 남아 있는 “만료되지 않은”
    ///      자동 갱신 구독 트랜잭션만 반환합니다. (환불된 항목은 제외)
    ///   2) iOS 15에서는 renewalInfo 프로퍼티가 제공되지 않아 “해지 예약됨” 여부를
    ///      판단할 수 없습니다. 만료 시점을 비교하여 UI를 갱신해야 합니다.
    @MainActor
    func fetchCurrentSubscriptions() async throws {
        for await verificationResult in Transaction.currentEntitlements {
            switch verificationResult {
            case .unverified(_, let error):
                print("🔴 [검증 실패] 트랜잭션 검증 실패: \(error.localizedDescription)")

            case .verified(let transaction):
                let id          = transaction.productID
                let type        = transaction.productType
                let revokedAt   = transaction.revocationDate

                print("""
                📦 [트랜잭션 정보]
                  • 상품 ID: \(id)
                  • 상품 타입: \(type)
                """)

                guard let products = try? await Product.products(for: [id]) else { continue }
                guard let product = products.first else { continue }
                
                // 환불·취소 여부
                if let revoke = revokedAt {
                    print("❌ [환불/취소됨] 취소일: \(revoke)")
                    continue
                }

                // 자동갱신 상태
                guard let statuses = try await product.subscription?.status else { continue }
                for status in statuses {
                    switch status.state {
                    case .expired, .revoked:
                        continue  // 만료되거나 취소된 구독은 무시합니다.
                    default:
                        guard case .verified(let renewal) = status.renewalInfo,
                              case .verified(let transaction) = status.transaction else {
                            //return "앱 스토어에서 구독 상태를 확인할 수 없습니다. 개발자에게 문의해주세요. (error 1)"
                            continue
                        }
                        print("""
                        🔄 [갱신 정보]
                          • 자동갱신 여부: \(renewal.willAutoRenew)
                          • 결제 문제 감지 여부: \(renewal.isInBillingRetry)
                          • 현재 상품 ID: \(renewal.currentProductID)
                          • 구독 ID: \(renewal.originalTransactionID)
                        """)

                        // 최종 상태 구분
                        if renewal.willAutoRenew {
                            print("✅ 활성 구독 · 자동갱신 중")
                        } else if !renewal.willAutoRenew {
                            print("⚠️ 활성 구독이지만 자동갱신 꺼짐 (만료일: \(String(describing: transaction.expirationDate)))")
                        } else {
                            print("⏳ 구독 만료 예정 또는 이미 만료됨")
                        }
                    }
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.transactionVerificationFailed
        case .verified(let safe):
            return safe
        }
    }
    
}


