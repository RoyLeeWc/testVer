//
//  SplashCoordinator.swift
//  LezhinComics
//
//  Created by joki on 2024/03/13.
//  Copyright © 2024 Lezhin Entertainment. All rights reserved.
//

import UIKit
import Swinject
import SwinjectStoryboard

protocol SplashCoordinatorDelegate: AnyObject {
    func failForServiceUnavailable(_ coordinator: Coordinator )
    func successLoad(_ coordinator: Coordinator)
}

class SplashCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    weak var delegate: SplashCoordinatorDelegate?
    private(set) var window: UIWindow?
    
    init(window: UIWindow?) {
        self.window = window
    }

    func start() {
        
        guard let splashViewController = AppContext.container.resolve(SplashViewController.self) else { return }
        
        splashViewController.delegate = self
        self.window?.rootViewController = splashViewController
        self.window?.makeKeyAndVisible()
    }
}

extension SplashCoordinator: SplashViewControllerDelegate {
    func failForServiceUnavailable() {
        self.delegate?.failForServiceUnavailable(self)
    }
    
    func successLoad() {
        self.delegate?.successLoad(self)
    }
}
