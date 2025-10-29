//
//  AppCoordinator.swift
//  LezhinComics
//
//  Created by joki on 2024/03/13.
//  Copyright © 2024 Lezhin Entertainment. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private(set) var window: UIWindow?
    
    var isLoaded: Bool = false
    
    init(window: UIWindow?) {
        self.window = window
    }

    func start() {
        
        //현지화 문구 설정
        if let isUserSetLanguageCode = Defaults.isUserSetLanguageCode {
            Defaults.currentSetLanguageCode
        } else {
            let currentLanguageCode = LZSUtil.getPrimaryLanguageCode()
            if AppContext.shared.supportLanguages.contains(currentLanguageCode) {
                Defaults.currentSetLanguageCode = currentLanguageCode
            } else {
                Defaults.currentSetLanguageCode = "en"
            }
        }
        
        if isLoaded {
            let mainCoordinator = MainCoordinator(window: self.window)
            mainCoordinator.start()
            addChildCoordinator(mainCoordinator)
        } else {
            let splashCoordinator = SplashCoordinator(window: self.window)
            splashCoordinator.delegate = self
            splashCoordinator.start()
            addChildCoordinator(splashCoordinator)
        }
    }
    
//    func showServiceCheckViewController(state: VersionModel?) {
//        let coordinator = ServiceCheckingCoordinator(window: self.window, state: state)
//        coordinator.delegate = self
//        coordinator.start()
//        addChildCoordinator(coordinator)
//    }
}

extension AppCoordinator: SplashCoordinatorDelegate {
    
    func failForServiceUnavailable(_ coordinator: Coordinator) {
        removeChildCoordinator(coordinator)
        exit(0)
    }
    
    func successLoad(_ coordinator: Coordinator) {
        removeChildCoordinator(coordinator)
        self.isLoaded = true
        self.start()
    }
}
