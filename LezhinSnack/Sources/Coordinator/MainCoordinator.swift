//
//  MainCoordinator.swift
//  LezhinComics
//
//  Created by joki on 2024/03/13.
//  Copyright © 2024 Lezhin Entertainment. All rights reserved.
//

import UIKit

protocol MainCoordinatorDelegate: AnyObject {
}

class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    weak var delegate: MainCoordinatorDelegate?
    private(set) var window: UIWindow?
    
    init(window: UIWindow?) {
        self.window = window
    }

    func start() {
        let tabBarViewController = TabBarViewController()
        tabBarViewController.modalTransitionStyle = .crossDissolve
        self.window?.rootViewController = tabBarViewController
        self.window?.makeKeyAndVisible()
    }
}
