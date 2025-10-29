//
//  MarkTypeDTO.swift
//  LezhinSnack
//
//  Created by lwc on 9/15/25.
//

enum MarkTypeDTO: String, Codable, CaseIterable {
    case up    = "UP"
    case new   = "NEW"
    case top10 = "TOP_10"
    case unknown = "UNKNOWN" // 예외 대비
    
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        let raw = (try? c.decode(String.self)) ?? "UNKNOWN"
        self = MarkTypeDTO(rawValue: raw) ?? .unknown
    }
}
