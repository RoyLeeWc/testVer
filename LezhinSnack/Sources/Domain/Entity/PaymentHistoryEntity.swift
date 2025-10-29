//
//  PaymentHistoryEntity.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/27/25.
//

import Foundation

//struct PaymentHistoryEntity: Hashable {
//    
//    let title: String
//    let id = UUID()
//    let isCoinProduct = Bool.random()
//    
//}

// MARK: - Entities
struct PaymentHistoryEntity: Hashable {
    let tradeId: String
    let paymentMenuType: PaymentMenuType
    let amount: Int
    let currencyType: CurrencyType
    let periodType: PeriodType?
    let createdAt: Int64
}

struct PaymentDetailEntity: Hashable {
    let tradeId: String
    let paymentMenuType: PaymentMenuType
    let status: PaymentStatus
    let amount: Int
    let currencyType: CurrencyType
    let coin: Int?
    let periodType: PeriodType?
    let paymentProviderType: PaymentProviderType
    let createdAt: Int64
}

// MARK: - Mapper
extension PaymentHistoryPageDTO {
    func toEntity() -> PagedEntity<PaymentHistoryEntity> {
        let items = content.map {
            PaymentHistoryEntity(
                tradeId: $0.tradeId,
                paymentMenuType: PaymentMenuType(rawValue: $0.paymentMenuType),
                amount: $0.amount,
                currencyType: CurrencyType(rawValue: $0.currencyType),
                periodType: PeriodType(rawValue: $0.periodType),
                createdAt: $0.createdAt
            )
        }
        return PagedEntity(
            items: items,
            page: number,
            size: size,
            isFirst: first,
            isLast: last,
            totalOnPage: numberOfElements
        )
    }
}

extension PaymentDetailDataDTO {
    func toEntity() -> PaymentDetailEntity {
        PaymentDetailEntity(
            tradeId: tradeId,
            paymentMenuType: PaymentMenuType(rawValue: paymentMenuType),
            status: PaymentStatus(rawValue: status),
            amount: amount,
            currencyType: CurrencyType(rawValue: currencyType),
            coin: coin,
            periodType: periodType.flatMap { PeriodType(rawValue: $0) } ?? nil,
            paymentProviderType: PaymentProviderType(rawValue: paymentProviderType),
            createdAt: createdAt
        )
    }
}

// MARK: - Enums (Domain)

enum CurrencyType: String, Decodable, Hashable {
    case krw = "KRW"
    case usd = "USD"
    case jpy = "JPY"
    case cny = "CNY"
    case unknown
    
    init(rawValue: String) {
        switch rawValue {
        case "KRW": self = .krw
        case "USD": self = .usd
        case "JPY": self = .jpy
        case "CNY": self = .cny
        default:    self = .unknown
        }
    }
}

enum PeriodType: String, Decodable, Hashable {
    case oneTimePurchase = "ONE_TIME_PURCHASE"
    case monthly         = "MONTHLY"
    case annual          = "ANNUAL"
    case unknown
    
    init(rawValue: String) {
        switch rawValue {
        case "ONE_TIME_PURCHASE": self = .oneTimePurchase
        case "MONTHLY":           self = .monthly
        case "ANNUAL":            self = .annual
        default:                  self = .unknown
        }
    }
}

enum PaymentStatus: String, Decodable, Hashable {
    case complete = "COMPLETE"
    case fail     = "FAIL"
    case cancel   = "CANCEL"
    case cancelPg = "CANCEL_PG"
    case unknown
    
    init(rawValue: String) {
        switch rawValue {
        case "COMPLETE":  self = .complete
        case "FAIL":      self = .fail
        case "CANCEL":    self = .cancel
        case "CANCEL_PG": self = .cancelPg
        default:          self = .unknown
        }
    }
}

enum PaymentProviderType: String, Decodable, Hashable {
    case iosApp  = "IOS_APP"
    case andPlay = "AND_PLAY"
    case unknown
    
    init(rawValue: String) {
        switch rawValue {
        case "IOS_APP":  self = .iosApp
        case "AND_PLAY": self = .andPlay
        default:         self = .unknown
        }
    }
}

extension CurrencyType {
    var code: String {
        switch self {
        case .krw: return "KRW"
        case .usd: return "USD"
        case .jpy: return "JPY"
        case .cny: return "CNY"
        case .unknown: return "KRW"
        }
    }
    var preferredLocale: Locale {
        switch self {
        case .krw: return Locale(identifier: "ko_KR")
        case .usd: return Locale(identifier: "en_US")
        case .jpy: return Locale(identifier: "ja_JP")
        case .cny: return Locale(identifier: "zh_CN")
        case .unknown: return Locale(identifier: "ko_KR")
        }
    }
}

// 포맷터 헬퍼 (천단위만, 기호 없이)
enum MoneyFormatter {
    static func text(amount: Int, currency: CurrencyType) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = currency.preferredLocale
        f.maximumFractionDigits = 0
        let body = f.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "\(currency.code) \(body)"
    }
}
