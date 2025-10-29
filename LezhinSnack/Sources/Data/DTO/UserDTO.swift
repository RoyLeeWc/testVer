//
//  UserDTOs.swift
//  LezhinSnack
//
//  Created by lwc on 9/30/25.
//

// 유저정보
struct UserInfoDTO: Decodable {
    let responseCode: String
    let data: UserInfoResponseDTO?
    let errorData: ErrorDataDTO?
}

struct UserInfoResponseDTO: Decodable {
    let userId: Int
    let email: String?
    let nickname: String
    let isGuest: Bool
    let joinType: String
    let createdAt: Int64        // 샘플값이 ms(13자리) 형태. 일단 Int64로 수용
}

// 닉네임 수정
struct UpdateNicknameDTO: Decodable {
    let responseCode: String
    let data: UpdateNicknameResponseDTO?
    let errorData: ErrorDataDTO?
}

struct UpdateNicknameResponseDTO: Decodable {
    let userId: Int
    let nickname: String
}

// 탈퇴 사유 목록
struct WithdrawalReasonsDTO: Decodable {
    let responseCode: String
    let data: [WithdrawalReasonItemDTO]?
    let errorData: ErrorDataDTO?
}

struct WithdrawalReasonItemDTO: Decodable {
    let withdrawalCategoryId: Int
    let orderNumber: Int
    let languageType: String
    let title: String
}

// 회원탈퇴 결과
struct UserWithdrawalDTO: Decodable {
    let responseCode: String
    let data: UserWithdrawalResultDTO?
    let errorData: ErrorDataDTO?
}

// 구독 정보 조회
struct UserWithdrawalResultDTO: Decodable {
    let userId: Int
    let deletedAt: Int64
}
