//
//  InAppPurchsaeEntity.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/20/25.
//

import Foundation
/// In-App Purchase 결과를 나타내는 엔티티
struct InAppPurchaseEntity {
    /// 결제타입
    let inAppPurchaseType: InAppPurchaseType
    
    /// 결제 금액 (예: 1000.00원)
    let amount: Int
    
    /// 결제 일시
    let purchaseDate: Date
    
    /// 충전 코인
    let purchaseCoin: Int?
    
    /// 결제 주기 (월별, 연별 등) - 구독형인지 일반 구매인지에 따라 nil일 수 있음
    let purchasePeriod: String?
    
    /// 결제 수단 (예: "CreditCard", "ApplePay", "PayPal" 등)
    let paymentMethod: String
}

