//
//  NoticeListDTO.swift
//  LezhinSnack
//
//  Created by lwc on 10/20/25.
//

struct NoticeListDTO: Decodable {
    let responseCode: String
    let data: [NoticeListItemDTO]?
    let errorData: ErrorDataDTO?
}

struct NoticeListItemDTO: Decodable {
    let noticeId: Int
    let categoryId: Int
    let categoryTitle: String
    let title: String
    let createdAt: Int64
    let isPinned: Bool
}

extension NoticeListItemDTO {
    func toEntity() -> NoticeListEntity {
        .init(
            noticeId: noticeId,
            categoryId: categoryId,
            categoryTitle: categoryTitle,
            title: title,
            createdAt: createdAt,
            isPinned: isPinned
        )
    }
}
