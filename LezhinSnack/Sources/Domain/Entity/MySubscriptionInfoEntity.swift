//
//  MySubscriptionInfoEntity.swift
//  LezhinSnack
//
//  Created by lwc on 10/1/25.
//

struct MySubscriptionInfoEntity: Hashable {
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
    let periodType: PeriodType
    let platformType: PlatformType
    let paymentDay: Int?
    let paymentMonth: Int?

    enum PeriodType { case oneTime, monthly, annual, unknown }
    enum PlatformType { case ios, android, unknown }
}
