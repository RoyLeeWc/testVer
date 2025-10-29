//
//  AuthProvider.swift
//  LezhinSnack
//
//  Created by 이우찬 on 9/9/25.
//

import Foundation

// 서버 엔드포인트에서 쓰는 Provider 값들
// ex) /auth/login/GOOGLE, /auth/login/APPLE ...

// swiftlint:disable identifier_name
enum AuthProvider: String {
    //  신규 메인 4종
    case GOOGLE
    case APPLE
    case FACEBOOK
    case LEZHIN
    case IOS_GUEST
}
// swiftlint:enable identifier_name

enum DRMType: String {
    case widevine = "WIDEVINE"
    case fairplay = "FAIRPLAY"
}

