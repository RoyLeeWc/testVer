//
//  HomeSectionEntity.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/12/25.
//

import UIKit

struct HomeSectionEntity: Hashable {
    let id: String
    let title: String
    let mockImageName: String? = nil
    var thumbnailImagePath: String? = nil
    let color: UIColor?
    var isPlaceholder: Bool = false
    
    init(id: String,
         title: String,
         color: UIColor? = nil,
         thumbnailImagePath: String? = nil,
         isPlaceholder: Bool = false) {
        self.id    = id
        self.title = title
        self.color = color
        self.thumbnailImagePath = thumbnailImagePath
        self.isPlaceholder = isPlaceholder
    }
    // ✅ Diffable에서 동일 아이템 판별을 id로만 하게
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
        static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}
