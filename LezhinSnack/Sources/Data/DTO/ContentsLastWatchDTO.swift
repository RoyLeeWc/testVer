//
//  ContentsLastWatchDTO.swift
//  LezhinSnack
//
//  Created by lwc on 9/11/25.
//

import Foundation


struct ContentsLastWatchDTO: Decodable {
    let responseCode: String
    let data: [ContentsLastWatcItemDTO]
    let errorData: ErrorDataDTO?
}


struct ContentsLastWatcItemDTO: Decodable {
    let contentsId: String
    let contentsAlias: String
    let thumbnailUrl: String
    let currentEpisode: Int
    let maxEpisode: Int
}
