//
//  UIApplication+Extension.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/5/25.
//

import UIKit

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindowInConnectedScenes?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    
    var keyWindowInConnectedScenes: UIWindow? {
        return self.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first { $0.isKeyWindow }
    }
    
    var topViewController: UIViewController? {
        guard let rootViewController = keyWindowInConnectedScenes?.rootViewController else {
            return nil
        }
        return rootViewController.getTopViewController()
    }
    
    func open(urlString: String) {
        guard let url = URL(string: urlString), canOpenURL(url) else { return }
        open(url)
    }
    
    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first
    }
    
    var safeAreaInsets: UIEdgeInsets {
        keyWindow?.safeAreaInsets ?? .zero
    }
    
    var statusBarHeight: CGFloat {
        safeAreaInsets.top
    }
}
