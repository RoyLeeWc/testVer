//
//  ErrorResponseDTO.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/2/25.
//

struct EmptyResponseDTO: Decodable {
    let responseCode: String
    let data: [String: String]?
    let errorData: ErrorDataDTO?
}

// 실제 에러 정보를 담는 구조체
struct ErrorDataDTO: Decodable {
    let code: String
    let defaultMessage: String
    let translations: [String: String]
}
