//
//  MarkEntity.swift
//  LezhinSnack
//
//  Created by lwc on 9/15/25.
//

import Foundation

struct MarkEntity: Hashable {
    let type: MarkType
}

enum MarkType: String, Hashable, CaseIterable {
    case up    = "UP"
    case new   = "NEW"
    case top10 = "TOP_10"
    case unknown = "UNKNOWN"

    init(dto: MarkTypeDTO) {
        self = MarkType(rawValue: dto.rawValue) ?? .unknown
    }
}
extension MarkEntity {
    init(dto: MarkTypeDTO) {
        self.init(type: MarkType(dto: dto))
    }
}
