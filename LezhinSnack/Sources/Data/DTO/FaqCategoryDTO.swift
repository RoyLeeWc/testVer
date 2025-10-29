//
//  FaqCategoryDTO.swift
//  LezhinSnack
//
//  Created by lwc on 10/20/25.
//

// FaqCategoryDTO.swift

struct FaqCategoryListDTO: Decodable {
    let responseCode: String
    let data: [FaqCategoryItemDTO]?
    let errorData: ErrorDataDTO?
}

struct FaqCategoryItemDTO: Decodable {
    let categoryId: Int
    let name: String
}

extension FaqCategoryItemDTO {
    func toEntity() -> FaqCategoryEntity {
        .init(categoryId: categoryId, name: name)
    }
}
