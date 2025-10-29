//
//  DisplayVideoDTO.swift
//  LezhinSnack
//
//  Created by lwc on 9/18/25.
//


import Foundation

struct DisplayVideoDTO: Decodable {
    let responseCode: String?            // "SUCCESS" | "ERROR"
    let data: DisplayVideoDataDTO?
    let errorData: ErrorDataDTO?
}

struct DisplayVideoDataDTO: Decodable {
    let videoId: String?
    let episodeId: String?
    let contentsId: String?
    let alias: String?
    let manifestPath: String?
    let drmToken: String?
}
