//
//  SubscriptionDTO.swift
//  LezhinSnack
//
//  Created by lwc on 10/1/25.
//

struct MySubscriptionDTO: Decodable {
    let responseCode: String
    let data: MySubscriptionDataDTO?
    let errorData: ErrorDataDTO?
}

struct MySubscriptionDataDTO: Decodable {
    let userId: Int
    let subscriptionId: String
    let title: String
    let productCode: String
    let isActive: Bool
    let startedAt: Int64?
    let endedAt: Int64?
    let lastPaymentAt: Int64?
    let nextPaymentAt: Int64?
    let gracePeriodEndAt: Int64?
    let isAutoRenewalEnabled: Bool
    let periodType: String    // "ONE_TIME_PURCHASE", "MONTHLY", "ANNUAL"
    let platformType: String  // "IOS", "ANDROID"
    let paymentDay: Int?
    let paymentMonth: Int?
}

extension MySubscriptionDataDTO {
    func toEntity() -> MySubscriptionInfoEntity {
        let period: MySubscriptionInfoEntity.PeriodType = {
            switch periodType {
            case "ONE_TIME_PURCHASE": return .oneTime
            case "MONTHLY":           return .monthly
            case "ANNUAL":            return .annual
            default:                  return .unknown
            }
        }()
        let platform: MySubscriptionInfoEntity.PlatformType = {
            switch platformType {
            case "IOS":     return .ios
            case "ANDROID": return .android
            default:        return .unknown
            }
        }()
        return .init(
            userId: userId,
            subscriptionId: subscriptionId,
            title: title,
            productCode: productCode,
            isActive: isActive,
            startedAt: startedAt,
            endedAt: endedAt,
            lastPaymentAt: lastPaymentAt,
            nextPaymentAt: nextPaymentAt,
            gracePeriodEndAt: gracePeriodEndAt,
            isAutoRenewalEnabled: isAutoRenewalEnabled,
            periodType: period,
            platformType: platform,
            paymentDay: paymentDay,
            paymentMonth: paymentMonth
        )
    }
}
