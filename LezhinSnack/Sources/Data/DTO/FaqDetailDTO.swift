//
//  FaqDetailDTO.swift
//  LezhinSnack
//
//  Created by lwc on 10/20/25.
//

struct FaqDetailDTO: Decodable {
    let responseCode: String
    let data: FaqDetailItemDTO?
    let errorData: ErrorDataDTO?
}

struct FaqDetailItemDTO: Decodable {
    let faqId: Int
    let categoryId: Int
    let categoryName: String
    let question: String
    let answer: String
}

extension FaqDetailItemDTO {
    func toEntity() -> FaqDetailEntity {
        .init(
            faqId: faqId,
            categoryId: categoryId,
            categoryName: categoryName,
            question: question,
            answer: answer
        )
    }
}
