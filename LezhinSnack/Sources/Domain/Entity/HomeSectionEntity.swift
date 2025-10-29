//
//  HomeSectionEntity.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/12/25.
//

import UIKit

struct HomeSectionEntity: Hashable {
    let id = UUID()
    let title: String
    let mockImageName: String? = nil
    var thumbnailImagePath: String? = nil
    let color: UIColor?
    var isPlaceholder = false
    
    init(title: String,
         color: UIColor? = nil,
         thumbnailImagePath: String? = nil) {
        self.title = title
        self.color = color
        self.thumbnailImagePath = thumbnailImagePath
    }
}
