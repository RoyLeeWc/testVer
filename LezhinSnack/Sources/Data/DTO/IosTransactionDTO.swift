//
//  IosTransactionDTO.swift
//  LezhinSnack
//
//  Created by lwc on 10/22/25.
//

// IosTransactionDTO.swift
struct IosTransactionDTO: Decodable {
    let responseCode: String
    let data: IosTransactionDataDTO?
    let errorData: ErrorDataDTO?
}

struct IosTransactionDataDTO: Decodable {
    let userId: Int
    let redirectUrl: String?
    let amount: Double
    let currencyType: String
    let tradeId: String
    let paymentMenuType: String
    let paymentProviderName: String
    let transactionId: String
    let platform: String
    let paymentProviderMethod: String
    let paymentStatusType: String
    let chargeCoins: [IosChargeCoinDTO]
}

struct IosChargeCoinDTO: Decodable {
    let coinType: String
    let coinAmount: Int
    let coinExpiredPeriod: Int
}

extension IosTransactionDataDTO {
    func toEntity() -> IosTransactionEntity {
        .init(
            userId: userId,
            redirectUrl: redirectUrl,
            amount: amount,
            currencyType: currencyType,
            tradeId: tradeId,
            paymentMenuType: PaymentMenuType(rawValue: paymentMenuType),
            paymentProviderName: paymentProviderName,
            transactionId: transactionId,
            platform: platform,
            paymentProviderMethod: paymentProviderMethod,
            paymentStatusType: paymentStatusType,
            chargeCoins: chargeCoins.map { $0.toEntity() }
        )
    }
}

extension IosChargeCoinDTO {
    func toEntity() -> IosChargeCoinEntity {
        .init(
            coinType: coinType,
            coinAmount: coinAmount,
            coinExpiredPeriod: coinExpiredPeriod
        )
    }
}

extension Array where Element == IosChargeCoinDTO {
    /// 타입 구분 없이 전체 코인 합
    var totalCoinAmount: Int {
        reduce(0) { $0 + $1.coinAmount }
    }

    /// 특정 coinType만 합산 (예: ["COIN","BONUS"])
    func amount(for kinds: Set<String>) -> Int {
        reduce(0) { sum, item in
            kinds.contains(item.coinType.uppercased()) ? (sum + item.coinAmount) : sum
        }
    }
}
