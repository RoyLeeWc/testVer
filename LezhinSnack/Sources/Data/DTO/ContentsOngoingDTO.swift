//
//  ContentsOngoingDTO.swift
//  LezhinSnack
//
//  Created by lwc on 9/11/25.
//

import Foundation


struct ContentsOngoingDTO: Decodable {
    let responseCode: String
    let data: [ContentsOngoingItemDTO]
    let errorData: ErrorDataDTO?
}


struct ContentsOngoingItemDTO: Decodable {
    let contentsId: String
    let contentsAlias: String
    let episodeId: String
    let contentsOpenedAt: Int64
    let coverImagePath: String?
    let episodeAlias: String
    let episodeOpenedAt: Int64
    let marks: [MarkTypeDTO]
}
