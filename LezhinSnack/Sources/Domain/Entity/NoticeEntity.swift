//
//  NoticeEntity.swift
//  LezhinSnack
//
//  Created by lwc on 10/17/25.
//

import Foundation

struct NoticeEntity: Hashable {
    let noticeId: Int
    let categoryTitle: String
    let title: String
    let contents: String
    let postedAt: Int64
    let viewCount: Int
}
