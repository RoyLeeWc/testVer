//
//  PaymentProviderEntity.swift
//  LezhinSnack
//
//  Created by lwc on 10/22/25.
//

struct PaymentProviderEntity: Hashable {
    let paymentProviderId: Int
    let paymentProviderName: String
    let paymentProviderMethod: String
    let paymentProviderRequestUrl: String
    let caution: String
}
