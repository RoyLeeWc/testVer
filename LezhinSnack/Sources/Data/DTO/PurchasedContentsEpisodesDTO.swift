//
//  PurchasedContentsEpisodesDTO.swift
//  LezhinSnack
//
//  Created by lwc on 9/25/25.
//

// 작품별 구매 회차 응답 DTO
struct PurchasedContentsEpisodesDTO: Decodable {
    let responseCode: String?
    let data: PurchasedContentsEpisodesDataDTO
    let errorData: ErrorDataDTO?
}



struct PurchasedContentsEpisodesDataDTO: Decodable {
    let contentsId: String
    let episodes: [PurchasedEpisodeInListDTO]
    
    
}

struct PurchasedEpisodeInListDTO: Decodable {
    let episodeId: String
    let purchaseType: String   // "POSSESSION"
}
