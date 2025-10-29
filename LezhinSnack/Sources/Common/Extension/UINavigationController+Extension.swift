//
//  Untitled.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/12/25.
//

import UIKit

extension UINavigationController {
    func pushHidesBottomBarViewController(_ viewController: UIViewController, animated: Bool = true) {
        viewController.hidesBottomBarWhenPushed = true
        self.pushViewController(viewController, animated: animated)
    }
}
