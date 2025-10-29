//
//  NoticeDTO.swift
//  LezhinSnack
//
//  Created by lwc on 10/17/25.
//

struct NoticeDTO: Decodable {
    let responseCode: String
    let data: NoticeItemDTO?
    let errorData: ErrorDataDTO?
}

struct NoticeItemDTO: Decodable {
    let noticeId: Int
    let categoryTitle: String
    let title: String
    let contents: String
    let postedAt: Int64  
    let viewCount: Int
}

extension NoticeItemDTO {
    func toEntity() -> NoticeEntity {
        .init(
            noticeId: noticeId,
            categoryTitle: categoryTitle,
            title: title,
            contents: contents,
            postedAt: postedAt,
            viewCount: viewCount
        )
    }
}
