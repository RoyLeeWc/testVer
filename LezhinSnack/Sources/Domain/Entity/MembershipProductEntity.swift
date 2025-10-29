//
//  MembershipProductEntity.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/30/25.
//


struct MembershipProductEntity: Codable, Hashable {
    var id: Int
    var membershipType: String
    var originalPrice: Double
    var salePersentage: Double
    var salePrice: Double
    var isBestProducts: Bool
}
