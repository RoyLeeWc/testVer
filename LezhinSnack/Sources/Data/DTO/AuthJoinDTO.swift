//
//  AuthJoinDTO.swift
//  LezhinSnack
//
//  Created by lwc on 9/8/25.
//

import Foundation


struct AuthJoinDTO: Decodable {
    let responseCode: String
    let data: AuthJoinDataDTO?
    let errorData: ErrorDataDTO?
}

struct AuthJoinDataDTO: Decodable {
    let joinType: String
    let userId: Int
    let email: String
}


