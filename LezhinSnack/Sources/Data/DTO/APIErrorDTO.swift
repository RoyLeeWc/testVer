//
//  APIErrorDTO.swift
//  LezhinSnack
//
//  Created by lwc on 9/9/25.
//

struct APIErrorDTO: Decodable {
    let code: String?
    let defaultMessage: String?
    let translations: [String: String]?
}
