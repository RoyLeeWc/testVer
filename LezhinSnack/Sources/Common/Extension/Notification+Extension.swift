//
//  Notification+Extension.swift
//  LZSShortForm
//
//  Created by 신진우 on 3/9/25.
//

import Foundation

public extension NSNotification {
    
    static let LZSMainBannerScrollDidBegin = Notification.Name.LZSMainBannerScrollDidBegin
    static let LZSMainBannerScrollDidEnd = Notification.Name.LZSMainBannerScrollDidEnd
    
    static let LZSOriginalScrollDidBegin = Notification.Name.LZSOriginalScrollDidBegin
    static let LZSOriginalScrollDidEnd = Notification.Name.LZSOriginalScrollDidEnd
    
    static let LZSChangeAccountNotification =  Notification.Name.LZSChangeAccountNotification
    static let LZSChangeLocaleNotification = Notification.Name.LZSChangeLocaleNotification
    static let LZSChangeLocaleStringNotification = Notification.Name.LZSChangeLocaleStringNotification
    
    /// 포그라운드 상태에서 푸시메시지 수신시에
    static let LZSForegroundPushReceiveNotification = Notification.Name.LZSForegroundPushReceiveNotification
    
    /// 뷰어, 회차리스트에서 회차 이동시에
    static let LZSChangeEpisodeReceiveNotification = Notification.Name.LZSChangeEpisodeReceiveNotification
    
    /// 뷰어, 회차리스트에서 회차 구매시에
    static let LZSPurchaseEpisodeReceiveNotification = Notification.Name.LZSPurchaseEpisodeReceiveNotification
    
    /// 뷰어, 회차리스트에서 미리 보기 선택시에
    static let LZSEarlyAccessReceiveNotification = Notification.Name.LZSEarlyAccessReceiveNotification
}

public extension Notification.Name {
    
    static let LZSMainBannerScrollDidBegin = Notification.Name("LZSMainBannerScrollDidBegin")
    static let LZSMainBannerScrollDidEnd = Notification.Name("MainBannerScrollDidEnd")
    
    static let LZSOriginalScrollDidBegin = Notification.Name("LZSOriginalScrollDidBegin")
    static let LZSOriginalScrollDidEnd = Notification.Name("LZSOriginalScrollDidEnd")
    
    static let LZSChangeAccountNotification = Notification.Name("LZSChangeAccount")
    static let LZSChangeLocaleNotification = Notification.Name("LZSChangeLocale")
    static let LZSChangeLocaleStringNotification = Notification.Name("LZSChangeLocaleString")
    
    /// 포그라운드 상태에서 푸시메시지 수신시에
    static let LZSForegroundPushReceiveNotification = Notification.Name("LZSForegroundPushReceiveNotification")
    
    
    /// 뷰어, 회차리스트에서 회차 이동시에
    static let LZSChangeEpisodeReceiveNotification = Notification.Name("LZSChangeEpisodeReceiveNotification")
    
    /// 뷰어, 회차리스트에서 회차 구매시에
    static let LZSPurchaseEpisodeReceiveNotification = Notification.Name("LZSPurchaseEpisodeReceiveNotification")
    
    /// 뷰어, 회차리스트에서 미리 보기 선택시에
    static let LZSEarlyAccessReceiveNotification = Notification.Name("LZSEarlyAccessReceiveNotification")
    
    /// 홈 진열 리스트 api 완료시점
    static let LZSHomeAllSectionsLoaded = Notification.Name("LZSHomeAllSectionsLoaded")
    
    /// 뷰어 라이센스에러
    static let drmLicenseFailed = Notification.Name("DRMLicenseFailed")
    
}
