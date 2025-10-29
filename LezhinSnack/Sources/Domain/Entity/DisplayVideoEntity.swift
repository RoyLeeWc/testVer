//
//  DisplayVideoEntity.swift
//  LezhinSnack
//
//  Created by lwc on 9/18/25.
//

struct DisplayVideoEntity: Hashable {
    let videoId: String
    let episodeId: String
    let contentsId: String
    let alias: String
    let manifestPath: String
    let drmToken: String
    
    /// ✅ 이 비디오 전용 CloudFront Cookie 헤더(전역 스토리지 사용하지 않음)
    let cfCookieHeader: String?
}
