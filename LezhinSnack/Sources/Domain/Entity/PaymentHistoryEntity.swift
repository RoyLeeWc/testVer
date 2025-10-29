//
//  PaymentHistoryEntity.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/27/25.
//

import Foundation

struct PaymentHistoryEntity: Hashable {
    
    let title: String
    let id = UUID()
    let isCoinProduct = Bool.random()
    
}
