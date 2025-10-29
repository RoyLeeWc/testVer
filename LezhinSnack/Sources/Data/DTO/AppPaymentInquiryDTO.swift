//
//  AppPaymentInquiryDTO.swift
//  LezhinSnack
//
//  Created by lwc on 10/23/25.
//

import Foundation

/// GET /app/payments/:tradeId 응답 DTO
struct AppPaymentInquiryDTO: Decodable {
   
    let responseCode: String
    let data: AppPaymentInquiryItem?
    let errorData: ErrorDataDTO?

}

struct AppPaymentInquiryItem: Decodable {
    let tradeId: String?
    /// 예: "RESERVE", "COMPLETE" 등
    let status: String?
    
    /// 결제 후 돌아갈 콜백 URL (문서 샘플 기준 String로 수용)
    let redirectUrl: String?
    
    /// 생성 시각 (epoch millis)
    let createdAt: Int?
    
    /// App Store transactionId (아직 없으면 null)
    let transactionId: String?
    
    /// 통화/금액(스키마에 존재하므로 Optional)
    let currency: String?
    let amount: Int?
    
    /// 스키마: paymentMenu, 샘플: paymentMenuType → 둘 다 수용
    let paymentMenuType: String?
    let paymentMenu: String?
    
    let productCode: String?
    
    /// 결제수단 정보
    let paymentProviderName: String?
    let paymentProviderMethod: String?
    
    /// 코인/보너스/무료 코인 및 만료일(존재 시)
    let chargeCoin: Int?
    let chargeBonusCoin: Int?
    let chargeFreeCoin: Int?
    let coinExpiredAt: Int?
    let bonusCoinExpiredAt: Int?
    let mileageExpiredAt: Int?
    
    let etc: String?
    let serviceId: String?
    
    /// 메뉴타입 정규화 (둘 중 하나 우선 반환)
    var paymentMenuNormalized: String? {
        paymentMenuType ?? paymentMenu
    }
}
