//
//  NoticeListEntity.swift
//  LezhinSnack
//
//  Created by lwc on 10/20/25.
//

struct NoticeListEntity: Hashable {
    let noticeId: Int
    let categoryId: Int
    let categoryTitle: String
    let title: String
    let createdAt: Int64
    let isPinned: Bool
}
