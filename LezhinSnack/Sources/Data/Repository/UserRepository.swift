//
//  UserRepository.swift
//  LezhinSnack
//
//  Created by 신진우 on 6/3/25.
//

import Foundation

protocol UserRepositoryProtocol {
    func fetchUserCoinBalance() async throws -> UserCoinEntity
    func updateUserNickname(to newNickname: String) async throws
}

class UserRepository: UserRepositoryProtocol {

     
    func fetchUserCoinBalance() async throws -> UserCoinEntity {
        let userCoinAPIRequest = UserCoinAPIRequest(parameters: nil)
        let userCoinResponse: KRUserCoinDTO = try await NetworkService.shared.requestAsync(userCoinAPIRequest)
        
        guard userCoinResponse.result == LZSConstant.ResponseSuccess,
              let data = userCoinResponse.data else {
            throw NSError(
                domain: "UserCoinError",
                code: -1,
                userInfo: nil
            )
        }
        
        return UserCoinEntity(coin: data.coin ?? 0,
                              bonusCoin: data.bonusCoin ?? 0,
                              expiringCoin: 0,
                              expiringWindowDays: 0)
    }
    
    
    func updateUserNickname(to newNickname: String) async throws {
        
    }
    
}
