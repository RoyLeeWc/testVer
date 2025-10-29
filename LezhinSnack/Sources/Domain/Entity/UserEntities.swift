//
//  UserEntities.swift
//  LezhinSnack
//
//  Created by lwc on 9/30/25.
//

import Foundation

struct UserInfoEntity: Hashable {
    public let userId: Int
    public let email: String?
    public let nickname: String
    public let isGuest: Bool
    public let joinType: JoinType
    public let createdAt: Int64     // 서버 원본 값 보존
}

enum JoinType: String {
    case apple = "APPLE"
    case facebook = "FACEBOOK"
    case google = "GOOGLE"
    case lezhin = "LEZHIN"
    case guest = "IOS_GUEST"
}

struct UpdateNicknameEntity: Hashable {
    public let userId: Int
    public let nickname: String
}

struct WithdrawalReasonEntity: Hashable {
    public let withdrawalCategoryId: Int
    public let orderNumber: Int
    public let languageType: String
    public let title: String
}

struct UserWithdrawalResultEntity: Hashable {
    public let userId: Int
    public let deletedAt: Int64
}


// MARK: - Mappers
extension UserInfoEntity {
    init?(dto: UserInfoResponseDTO?) {
        guard let userInfoDTO = dto else { return nil }
        self.init(
            userId: userInfoDTO.userId,
            email: userInfoDTO.email,
            nickname: userInfoDTO.nickname,
            isGuest: userInfoDTO.isGuest,
            joinType: JoinType(rawValue: userInfoDTO.joinType) ?? .guest,
            createdAt: userInfoDTO.createdAt
        )
    }
}

extension UpdateNicknameEntity {
    init?(dto: UpdateNicknameResponseDTO?) {
        guard let updateNicknameDTO = dto else { return nil }
        self.init(userId: updateNicknameDTO.userId, nickname: updateNicknameDTO.nickname)
    }
}

extension WithdrawalReasonEntity {
    init(dto: WithdrawalReasonItemDTO) {
        self.init(
            withdrawalCategoryId: dto.withdrawalCategoryId,
            orderNumber: dto.orderNumber,
            languageType: dto.languageType,
            title: dto.title
        )
    }
}

extension UserWithdrawalResultEntity {
    init?(dto: UserWithdrawalResultDTO?) {
        guard let userWithdrawalDTO = dto else { return nil }
        self.init(userId: userWithdrawalDTO.userId, deletedAt: userWithdrawalDTO.deletedAt)
    }
}

