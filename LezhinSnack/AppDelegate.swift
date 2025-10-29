//
//  AppDelegate.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/4/25.
//

import UIKit
import Combine
import SwiftyUserDefaults
import Swinject
import SwinjectStoryboard
import FirebaseCore
import FirebaseRemoteConfig
import FirebaseMessaging
import GoogleSignIn
import Kronos
import AVFAudio
import SkeletonView
import Toast
import EasyTipView

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    let container = Container()
    
    
    var remoteConfig: RemoteConfig?
    var cancellable: Cancellable?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Bundle.enableRuntimeLocalization()
    
        if let remoteNotification = launchOptions?[.remoteNotification] as? [AnyHashable: Any],
           let pushInfo = remoteNotification["aps"] as? [String: AnyObject] {
            Defaults.pendingPushDict = AppContext.shared.makePushDict(info: pushInfo)
        }
        
        setupAppLaunch()
        
        return true
    }
    
    func application(
      _ application: UIApplication,
      configurationForConnecting connectingSceneSession: UISceneSession,
      options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
          name: "Default Configuration",
          sessionRole: connectingSceneSession.role
        )
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
    
    
    func setRemoteConfig() {
        
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        
        // fetchInterval 값 설정: https://firebase.google.com/docs/remote-config/get-started?platform=ios&hl=ko#throttling
        settings.minimumFetchInterval = 0
        remoteConfig?.configSettings = settings
        remoteConfig?.addOnConfigUpdateListener { [weak self] configUpdate, error in
            if let error {
              print("Error: \(error)")
              return
            }
            
            guard let updatedKeys = configUpdate?.updatedKeys else { return }
            self?.configureRemoteKey(updatedKeys: updatedKeys)
            
        }
    }
    
    private func configureRemoteKey(updatedKeys: Set<String>) {
        remoteConfig?.activate { [weak self] changed, error in
            for key in updatedKeys {
                guard let value = self?.remoteConfig?.configValue(forKey: key).stringValue else { return }
                let localSavedString = LocalizedStringManager.shared.fetchLocalizedString(for: key)
                if !value.isEmpty && value != localSavedString {
                    LocalizedStringManager.shared.updateLocalizedString(for: key, with: value)
                    guard let valueString = LocalizedStringManager.shared.fetchLocalizedString(for: key ) else { return }
//                    onMain {
//                        // 커스텀 팝업 노출 테스트 코드
//                        let customPopup = CustomPopupView()
//                        customPopup.titleLabel.text = "확인 할 키 : \(key) "
//                        customPopup.contentLabel.text = "\(key) 의 벨류 :\(valueString) "
//                        PopupService.shared.showPopup(customPopup)
//                    }
                }
            }
            
            NotificationCenter.default.post(name: .LZSChangeLocaleStringNotification, object: nil)
            
        }
    }
    
    
    private func setupAppLaunch() {
        
        //전체적인 앱단 로그 출력
        
        //NTP로 시간 동기화
        Clock.sync(completion: { date, offset in
            printAppInfo()
        })
        
        
        //인앱결제 트랜잭션 리스너 등록
        TransactionManager.shared.startTransactionListener()
        
        
        //스윈잭션 스토리보드용 컨테이너 설정 및 의존성 주입
        SwinjectStoryboard.defaultContainer = AppContext.container
        AppContext.shared.injectDependency()
        
        //메모리 누수체크
        UIViewController.swizzleDeallocCheck()
        
//        Defaults.showLocalStringKey = true
        Defaults.showLocalStringKey = false
        
        //푸시 설정
        UNUserNotificationCenter.current().delegate = self
        
        //파이어베이스 설정
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try? audioSession.setCategory(.playback, mode: .moviePlayback)
            try? audioSession.setActive(true)
        } catch {
            print("오디오 세션 카테고리")
        }

        let darkBase = UIColor(.darkGray333)
        
        //스켈레톤 뷰 색상 설정
        SkeletonAppearance.default.tintColor = darkBase
        
        //그라디언트 동일 톤으로 변경
        SkeletonAppearance.default.gradient = SkeletonGradient(baseColor: darkBase)
        
        //툴팁 뷰 글로벌 설정        
        var preferences = EasyTipView.Preferences()
        preferences.drawing.font = .pretendardSemiBold(size: 11)
        preferences.drawing.foregroundColor = .white
        preferences.drawing.backgroundColor = .fillBrand
        preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.bottom
        preferences.drawing.cornerRadius = 6
        preferences.drawing.arrowHeight = 6
        preferences.drawing.arrowWidth = 8
        
        preferences.positioning.bubbleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 3, right: 0)
        preferences.positioning.contentInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        EasyTipView.globalPreferences = preferences
        
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    
    /// Firebase Cloud Messaging 등록 토큰을 수신했을 때 호출됩
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
    
    
    /// APNS(Apple Push Notification Service) 토큰 등록 성공 시 호출, FCM 토큰 등록
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        Messaging.messaging().apnsToken = deviceToken
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token =", token)
    }
    
    
    /// 포그라운드 상태에서 알림이 도착할 때 호출
    /// - Parameters:
    ///   - center: 알림 센터 인스턴스.
    ///   - notification: 수신된 알림 객체.
    ///   - completionHandler: 알림 표시 옵션을 지정하기 위한 클로저. 여기서는 소리, 뱃지, 배너 옵션이 적용
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        print("UNUserNotificationCenterDelegate willPresent notification = \(notification)")
        completionHandler([.sound, .badge, .banner])
    }
    
    
    /// 사용자가 알림에 상호작용했을 때 호출
    /// - Parameters:
    ///   - center: 알림 센터 인스턴스.
    ///   - response: 사용자의 상호작용 결과를 담고 있는 UNNotificationResponse 객체.
    ///   - completionHandler: 처리가 완료되었음을 알리기 위한 클로저.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let application = UIApplication.shared
        let notification = response.notification
        let userInfo = notification.request.content.userInfo
        
        if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            print("Message Closed")
        } else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            print("푸시 메시지 클릭 했을 때")
        }
        
        
        if let info = userInfo["aps"] as? Dictionary<String, AnyObject> {
            switch application.applicationState {
            case .active: NotificationCenter.default.post(name: .LZSForegroundPushReceiveNotification, object: AppContext.shared.makePushDict(info: info))
            case .inactive: NotificationCenter.default.post(name: .LZSForegroundPushReceiveNotification, object: AppContext.shared.makePushDict(info: info))
            case .background: break
            @unknown default: break
            }
        }
        completionHandler()
    }
    
    /// 원격 푸시 알림이 수신되었을 때 호출되는 메서드.
    ///
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        completionHandler(.newData)
    }
    
}


func printAppInfo() {
    //  시스템 Locale 정보를 가져오기 ( 활용 X, 체크용 ) -> 선호도 우선순위 언어랑 다른 return 값이 떨어짐
    //  언어코드 활용시 BalconyUtil.getPrimaryLanguageCode() 함수활용
    let localeIdentifier = Locale.current.identifier
    let regionCode = Locale.current.region?.identifier ?? "N/A"
    let localeLanguageCode = Locale.current.language.languageCode?.identifier ?? "N/A"
    
    
    printX("""
        
        ---------------------- 1. 게스트 모드 로그인 정보 ----------------------
        
        SNS ID   : \(AppContext.shared.deviceUniqueID)
        E-MAIL   : \(AppContext.shared.deviceUniqueID + "@apple_guest.com")
        NAME     : \( "")
        
        ---------------------- 2. 마지막 로그인 정보 ------------------------
        
        SNS ID   : \(Defaults.snsId)
        E-MAIL   : \(Defaults.userEmail)
        NAME     : \(Defaults.userName)
        
        ---------------------- 3. 디바이스 정보 -----------------------------
        
        DeviceModel     : \(AppContext.shared.deviceModelName)
        DeviceID        : \(AppContext.shared.deviceUniqueID)
        DeviceIPAddress : \(AppContext.shared.deviceIPAddress)
        
        ---------------------- 4. 시각 -------------------------------------
        
        Device Time               : \(Date())
        NTP Time                  : \(String(describing: Clock.now))
        BalconyUtil Time          : \(String(describing: LZSUtil.getCurrentTimeString()))
        BalconyUtil Time (unix)   : \(String(describing: LZSUtil.getCurrentTimeString(isUseUnixTime: true)))
        
        ---------------------- 5. 지역 및 언어 설정 -----------------------------
        
        Locale Identifier       : \(localeIdentifier)
        Region Code             : \(regionCode)
        System Language Code    : \(localeLanguageCode)
        Apple Primary Language  : \(LZSUtil.getPrimaryLanguageCode())
        
        --------------------------------------------------------------------
        """)
    
}

func onMain(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async { block() }
    }
}

func onMainAfter(delay: TimeInterval, _ block: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: block)
}
