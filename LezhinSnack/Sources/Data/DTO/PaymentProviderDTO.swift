//
//  PaymentProviderDTO.swift
//  LezhinSnack
//
//  Created by lwc on 10/22/25.
//

struct PaymentProviderDTO: Decodable {
    let responseCode: String
    let data: [PaymentProviderItemDTO]?
    let errorData: ErrorDataDTO?
}

struct PaymentProviderItemDTO: Decodable {
    let paymentProviderId: Int
    let paymentProviderName: String
    let paymentProviderMethod: String
    let paymentProviderRequestUrl: String
    let caution: String
}

extension PaymentProviderItemDTO {
    func toEntity() -> PaymentProviderEntity {
        .init(
            paymentProviderId: paymentProviderId,
            paymentProviderName: paymentProviderName,
            paymentProviderMethod: paymentProviderMethod,
            paymentProviderRequestUrl: paymentProviderRequestUrl,
            caution: caution
        )
    }
}
