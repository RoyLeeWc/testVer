//
//  SceneDelegate.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/10/25.

import UIKit
import Pulse
import FacebookCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    // 씬이 연결될 때 호출되는 메서드
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // 1. UIWindowScene 타입으로 변환
        guard let windowScene = scene as? UIWindowScene else { return }

        // 2. UIWindow 생성 및 속성 설정
        
        #if DEBUG
        URLSessionProxyDelegate.enableAutomaticRegistration()
        let window = NetworkDebugWindow(windowScene: windowScene)
        #else
        let window = UIWindow(windowScene: windowScene)
        #endif
        
        self.window = window

        // 3. 현지화 문자열 비동기 로드
        AppContext.shared.importAllLocalizedStrings { [weak self] result in
            onMain {
                
            }
        }

        // 4. AppCoordinator 초기화 및 시작
        let coordinator = AppCoordinator(window: window)
        self.appCoordinator = coordinator
        coordinator.start()

        // 5. 원격 구성(Remote Config) 설정 호출
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.setRemoteConfig()
        }

        // 6. 윈도우를 키 윈도우로 설정하고 화면 표시
        window.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        ApplicationDelegate.shared.application(UIApplication.shared, open: url, sourceApplication: nil, annotation: [UIApplication.OpenURLOptionsKey.annotation])
    }
    
}
