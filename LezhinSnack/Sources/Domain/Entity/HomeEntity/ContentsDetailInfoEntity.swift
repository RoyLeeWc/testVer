//
//  ContentsDetailInfoEntity.swift
//  LezhinSnack
//
//  Created by lwc on 9/11/25.
//

import Foundation


struct ContentsDetailInfoEntity: Hashable {
    let coverImagePath: String
    let title: String
    let genreTag: TagInfoEntity?
    let keywordTags: [TagInfoEntity]
}

extension ContentsDetailInfoEntity {
    init(dto: ContentsDetailInfoDTO) {
        self.coverImagePath = dto.coverImagePath
        self.title = dto.title
        self.genreTag = dto.genreTag.map(TagInfoEntity.init(dto:))
        self.keywordTags = dto.keywordTags.map(TagInfoEntity.init(dto:))
    }
}

extension ContentsDetailInfoEntity {
    /// 키워드 태그의 name만 뽑아 배열로 반환
    var keywordNames: [String] {
        (keywordTags ?? []).map { $0.name }
    }

    /// 최대 개수 제한이 필요하면 이거 사용
    func keywordNames(limit: Int) -> [String] {
        let names = (keywordTags ?? []).map { $0.name }
        return Array(names.prefix(limit))
    }
}

