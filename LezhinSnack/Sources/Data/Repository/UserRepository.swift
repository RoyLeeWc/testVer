//
//  UserRepository.swift
//  LezhinSnack
//
//  Created by 신진우 on 6/3/25.
//

import Foundation

protocol UserRepositoryProtocol {
    func fetchUserInfo() async throws -> UserInfoEntity
    func updateNickname(_ nickname: String) async throws -> UpdateNicknameEntity
    func fetchWithdrawalReasons() async throws -> [WithdrawalReasonEntity]
    func withdraw(categoryId: Int, reason: String) async throws -> UserWithdrawalResultEntity
    func fetchUserCoin() async throws -> UserCoinEntity
}

enum UserRepositoryError: Error {
    case api(code: String, message: String)
    case invalidData
}


class UserRepository: UserRepositoryProtocol {

    func fetchUserInfo() async throws -> UserInfoEntity {
        let req = UserInfoAPIRequest()
        let dto: UserInfoDTO = try await NetworkService.shared.requestAsync(req)
        guard dto.responseCode == "SUCCESS" else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "Fetch user info failed."
            throw UserRepositoryError.api(code: code, message: msg)
        }
        guard let entity = UserInfoEntity(dto: dto.data) else { throw UserRepositoryError.invalidData }
        return entity
    }
    
    func updateNickname(_ nickname: String) async throws -> UpdateNicknameEntity {
        let req = UpdateNicknameAPIRequest(nickname: nickname)
        let dto: UpdateNicknameDTO = try await NetworkService.shared.requestAsync(req)
        guard dto.responseCode == "SUCCESS" else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "Update nickname failed."
            throw UserRepositoryError.api(code: code, message: msg)
        }
        guard let entity = UpdateNicknameEntity(dto: dto.data) else { throw UserRepositoryError.invalidData }
        return entity
    }
    
    func fetchWithdrawalReasons() async throws -> [WithdrawalReasonEntity] {
        let req = WithdrawalReasonsAPIRequest()
        let dto: WithdrawalReasonsDTO = try await NetworkService.shared.requestAsync(req)
        guard dto.responseCode == "SUCCESS" else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "Fetch withdrawal reasons failed."
            throw UserRepositoryError.api(code: code, message: msg)
        }
        let list = (dto.data ?? []).map(WithdrawalReasonEntity.init(dto:))
        return list
    }
    
    func withdraw(categoryId: Int, reason: String) async throws -> UserWithdrawalResultEntity {
        let req = UserWithdrawalAPIRequest(withdrawalCategoryId: categoryId, reason: reason)
        let dto: UserWithdrawalDTO = try await NetworkService.shared.requestAsync(req)
        guard dto.responseCode == "SUCCESS" else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "Fetch withdrawal reasons failed."
            throw UserRepositoryError.api(code: code, message: msg)
        }
        guard let entity = UserWithdrawalResultEntity(dto: dto.data) else { throw UserRepositoryError.invalidData }
        return entity
    }
    
    func fetchUserCoin() async throws -> UserCoinEntity {
            let req = UserCoinAPIRequest()
            let dto: UserCoinDTO = try await NetworkService.shared.requestAsync(req)

            guard dto.responseCode == "SUCCESS", let data = dto.data else {
                let msg = dto.errorData?.defaultMessage ?? "Fetch withdrawal reasons failed."
                throw UserRepositoryError.api(code: dto.errorData?.code ?? "ERROR", message: msg)
            }
            return data.toEntity()
        }

    
}
