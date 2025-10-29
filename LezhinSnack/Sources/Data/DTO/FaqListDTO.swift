//
//  FaqListDTO.swift
//  LezhinSnack
//
//  Created by lwc on 10/20/25.
//

struct FaqListDTO: Decodable {
    let responseCode: String
    let data: [FaqItemDTO]?
    let errorData: ErrorDataDTO?
}

struct FaqItemDTO: Decodable {
    let faqId: Int
    let categoryId: Int
    let categoryName: String
    let question: String
    let answer: String
    let orderNumber: Int
}

extension FaqItemDTO {
    func toEntity() -> FaqEntity {
        .init(
            faqId: faqId,
            categoryId: categoryId,
            categoryName: categoryName,
            question: question,
            answer: answer,
            orderNumber: orderNumber
        )
    }
}
