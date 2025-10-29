//
//  FaqEntity.swift
//  LezhinSnack
//
//  Created by lwc on 10/20/25.
//

struct FaqEntity: Hashable {
    let faqId: Int
    let categoryId: Int
    let categoryName: String
    let question: String
    let answer: String
    let orderNumber: Int
}

