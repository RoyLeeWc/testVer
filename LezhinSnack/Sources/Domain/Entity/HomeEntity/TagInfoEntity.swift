//
//  TagInfoEntity.swift
//  LezhinSnack
//
//  Created by lwc on 9/11/25.
//

import Foundation

struct TagInfoEntity: Hashable {
    let tagId: String
    let name: String
}

extension TagInfoEntity {
    init(dto: TagInfoDTO) {
        self.tagId = dto.tagId
        self.name = dto.name
    }
}
