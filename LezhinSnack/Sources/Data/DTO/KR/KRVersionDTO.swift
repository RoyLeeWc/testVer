//
//  VersionModel.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/4/25.
//

import Foundation

class KRVersionDTO: Decodable {
    var hasNewApp: Bool
    var version: String
    var title: String
    var description: String
    var address: String
    var isCancelable: Bool
    var isServerMaintenance: Bool

    enum CodingKeys: String, CodingKey {
        case hasNewApp
        case version
        case title
        case description
        case address
        case isCancelable
        case isServerMaintenance
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        // decodeIfPresent를 사용하여 값이 없으면 기본값을 부여
        hasNewApp = try values.decodeIfPresent(Bool.self, forKey: .hasNewApp) ?? false
        version = try values.decodeIfPresent(String.self, forKey: .version) ?? ""
        title = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
        description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
        address = try values.decodeIfPresent(String.self, forKey: .address) ?? ""
        isCancelable = try values.decodeIfPresent(Bool.self, forKey: .isCancelable) ?? false
        isServerMaintenance = try values.decodeIfPresent(Bool.self, forKey: .isServerMaintenance) ?? false
    }
}
