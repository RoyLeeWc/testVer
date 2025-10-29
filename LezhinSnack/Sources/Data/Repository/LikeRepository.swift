//
//  LikeRepository.swift
//  LezhinSnack
//
//  Created by lwc on 9/22/25.
//

import Foundation

 protocol LikeRepositoryProtocol {
    func like(contentsId: String) async throws
    // ※ 언라이크 엔드포인트가 확정되면 여기에도 추가:
    // func unlike(contentsId: String) async throws
}

final class LikeRepository: LikeRepositoryProtocol {
    
    
}
