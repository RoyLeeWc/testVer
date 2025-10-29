//
//  PurchasedEpisodeEntity.swift
//  LezhinSnack
//
//  Created by lwc on 9/25/25.
//

enum PurchaseType: String, Decodable {
    case possession = "POSSESSION"
}

struct PurchasedEpisodeEntity: Hashable {
    let episodeId: String
    let purchaseType: PurchaseType
}

extension PurchasedEpisodeEntity {
    init(_ dto: PurchasedEpisodeInDetailDTO) {
        self.episodeId = dto.episodeId
        self.purchaseType = PurchaseType(rawValue: dto.purchaseType ?? "POSSESSION") ?? .possession
    }
    init(_ dto: PurchasedEpisodeInListDTO) {
        self.episodeId = dto.episodeId
        self.purchaseType = PurchaseType(rawValue: dto.purchaseType) ?? .possession
    }
}
