//
//  AppVerCheckDTO.swift
//  LezhinSnack
//
//  Created by lwc on 9/4/25.
//

struct AppVerCheckDTO: Decodable {
    let responseCode: String?           // "SUCCESS" / "FAILURE"
    let data: AppVerCheckData?
    let errorData: ErrorDataDTO?
}

struct AppVerCheckData: Decodable {
    let isNewAppVersion: Bool?    // 새 앱 버전있는지 여부
    let version: String?         // 최신 앱 버전 문자열 (예: '1.2.3')
    let title: String?           // 업데이트 팝업에 표시할 제목
    let description: String?     // 업데이트 팝업에 표시할 설명
    let downloadUrl: String?     // 새 버전 다운로드 URL
    let isForceUpdate: Bool?      // 강제 업데이트 여부
    
}
