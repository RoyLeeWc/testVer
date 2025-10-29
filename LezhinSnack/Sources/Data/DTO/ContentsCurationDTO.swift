//
//  ContentsCurationDTO.swift
//  LezhinSnack
//
//  Created by lwc on 9/11/25.
//

import Foundation


struct ContentsCurationDTO: Decodable {
    let responseCode: String
    let data: [ContentsCurationItemDTO]
    let errorData: ErrorDataDTO?
}


struct ContentsCurationItemDTO: Decodable {
    let contentsId: String
    let contentsAlias: String
    let contentsDetail: ContentsDetailInfoDTO?
    let badges: [BadgeTypeDTO]
}
