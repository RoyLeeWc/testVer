//
//  CoinProductEntity.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/30/25.
//

struct CoinProductEntity: Codable, Hashable {
    var id: Int
    var coinValue: String
    var originalPrice: Double
    var salePersentage: Double
    var salePrice: Double
    var isFirstPurchase: Bool
}
