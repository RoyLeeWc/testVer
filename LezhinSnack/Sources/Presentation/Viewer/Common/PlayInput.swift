//
//  PlayInput.swift
//  LezhinSnack
//
//  Created by lwc on 9/22/25.
//

// 홈 섹션 선택 최소 모델
struct PlayInput: Hashable {
    let contentsAlias: String
    let episodeAlias: String?
    init(contentsAlias: String, episodeAlias: String? = nil) {
        self.contentsAlias = contentsAlias
        self.episodeAlias = episodeAlias
    }
}
