//
//  PagedEntity.swift
//  LezhinSnack
//
//  Created by lwc on 10/1/25.
//

struct PagedEntity<T: Hashable>: Hashable {
    let items: [T]
    let page: Int
    let size: Int
    let isFirst: Bool
    let isLast: Bool
    let totalOnPage: Int
}
