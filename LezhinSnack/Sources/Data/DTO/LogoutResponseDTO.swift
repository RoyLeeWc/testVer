//
//  LogoutResponseDTO.swift
//  LezhinSnack
//
//  Created by lwc on 9/9/25.
//

struct LogoutResponseDTO: Decodable {
    let responseCode: String
    let data: DataField
    let errorData: ErrorDataDTO?

    struct DataField: Decodable {}
}
