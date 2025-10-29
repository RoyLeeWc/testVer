//
//  FaqDetailEntity.swift
//  LezhinSnack
//
//  Created by lwc on 10/20/25.
//

struct FaqDetailEntity: Hashable {
    let faqId: Int
    let categoryId: Int
    let categoryName: String
    let question: String
    let answer: String
}
