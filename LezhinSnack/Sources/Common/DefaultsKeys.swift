//
//  DefaultsKeys.swift
//  Bomtoon_Renewal
//
//  Created by jinu0115 on 2/3/25.
//

import UIKit
import SwiftyUserDefaults

extension DefaultsKeys {
    
    /// 로컬에 저장 된 현지화 문구를 한번 임포트 했을경우를 나타내는 플래그
    var isAlreadyImportLocalString: DefaultsKey<Bool> { .init("isAlreadyImportLocalString", defaultValue: false) }
    
    /// 백그라운드에서 수신한 팬딩 된 푸시가 있는경우
    var pendingPushDict: DefaultsKey<[String: String]?> { .init("pendingPushDict",defaultValue: nil) }
    
    /// 알람, 카메라등 권한 팝업 초기호출 여부
    var isShowPermissionPopup: DefaultsKey<Bool> { .init("showPermissionPopup", defaultValue: false) }
    
    /// 현지화문구 '키' 확인용 플래그,
    ///  - true  : 현지화 문구 '키' 가 노출
    ///  - false : 현지화 문구 '벨류'가 노출
    var showLocalStringKey: DefaultsKey<Bool> { .init("showLocalStringKey", defaultValue: false) }
    
    /// 유저가 언어변경을 선택했는지 판별하는 플래그
    var isUserSetLanguageCode: DefaultsKey<Bool?> { .init("isUserSetLanguageCode", defaultValue: nil) }
    
    /// 앱 전역으로 설정할 언어코드
    var currentSetLanguageCode: DefaultsKey<String> { .init("userSetLanguageCode", defaultValue: "en") }
    
    /// 아이피주소
    var ipAddress: DefaultsKey<String> { .init("ipAddress", defaultValue: LZSUtil.getIPAddress()) }
    
    /// 엑세스 토큰
    var accessToken: DefaultsKey<String> { .init("accessToken", defaultValue: "") }
    
    /// 리프레쉬 토큰
    var refreshToken: DefaultsKey<String> { .init("refreshToken", defaultValue: "") }
    
    /// 엑세스 토큰 만료시간
    var accessTokenExpiryDate: DefaultsKey<Date?> { .init("accessTokenExpiryDate", defaultValue: nil) }
    
    /// 리프레시 토큰 만료시간
    var refreshTokenExpiryDate: DefaultsKey<Date?> { .init("refreshTokenExpiryDate", defaultValue: nil) }
    // 토큰만료 계산을 위한 서버시간과의 offset
    var serverTimeOffset: DefaultsKey<TimeInterval> { .init("serverTimeOffset", defaultValue: 0) }
    
    
    /// 인앱결재 - 마지막 트랜잭션 ID
    var transactionId: DefaultsKey<String> { .init("transactionId", defaultValue: "") }
    
    // 로그인 ( Auth )
    var guestModeId: DefaultsKey<String> { .init("guestModeId", defaultValue: "") }
    var userId: DefaultsKey<String> { .init("userId", defaultValue: "") }
    var snsId: DefaultsKey<String> { .init("snsId", defaultValue: "") }
    var userEmail: DefaultsKey<String> { .init("userEmail", defaultValue: "") }
    var userName: DefaultsKey<String> { .init("userName", defaultValue: "") }
    var userLoginType: DefaultsKey<String> { .init("userLoginType", defaultValue: SnsLoginType.guestMode.rawValue) }
    
    var lastLoginType: DefaultsKey<String?> { .init("userLastLoginType", defaultValue: nil )}
    
}
