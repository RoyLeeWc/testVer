//
//  LZSnackToastHelper.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/8/25.
//

import UIKit
import Toast

struct LZSnackToastHelper {
    
    static func showOnce(on view: UIView?,
                         toast toastView: UIView,
                         duration: TimeInterval = 2.0,
                         position: ToastPosition = .bottom) {
        
        let targetView: UIView
        if let view = view {
            targetView = view
        } else {
            let activeScene = UIApplication.shared.connectedScenes
                .first { scene in
                    guard let windowScene = scene as? UIWindowScene else { return false }
                    return windowScene.activationState == .foregroundActive
                } as? UIWindowScene
            
            guard let keyWindow = activeScene?.windows.first(where: { $0.isKeyWindow }),
                  let rootVC = keyWindow.rootViewController
            else { return }
            
            targetView = rootVC.getTopViewController().view
        }
        
        toastView.sizeToFit()
        targetView.hideAllToasts()
        targetView.showToast(toastView, duration: duration, position: position)
    }
    
}
