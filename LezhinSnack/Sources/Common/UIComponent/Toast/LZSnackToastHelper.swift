//
//  LZSnackToastHelper.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/8/25.
//

import UIKit
import Toast

struct LZSnackToastHelper {
    // 현재 포그라운드 활성 Scene의 keyWindow
    private static func keyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?
            .windows
            .first { $0.isKeyWindow }
    }
    
    /// 커스텀 뷰로 토스트 1개만 노출 (중복 제거) + bottomMargin으로 세밀 위치 조정
    static func showOnce(on view: UIView? = nil,
                         toast toastView: UIView,
                         duration: TimeInterval = 2.0,
                         position: ToastPosition = .bottom,
                         bottomMargin: CGFloat? = nil,
                         allowDuplicate: Bool = false,
                         onDismiss: (() -> Void)? = nil) {
        
        DispatchQueue.main.async {
            guard let host = view ?? keyWindow() else { return }
            
            if !allowDuplicate {
                host.hideAllToasts(includeActivity: true, clearQueue: true)
            }
            
            toastView.sizeToFit()
            let completion: (Bool) -> Void = { _ in onDismiss?() } //토스트가 사라지면 호출
            
            if position == .bottom, let margin = bottomMargin {
                // ✅ safe area + margin만큼 위로 올리기
                let safeBottom = host.safeAreaInsets.bottom
                let halfH = toastView.bounds.height / 2
                var y = host.bounds.height - safeBottom - margin - halfH
                
                // 화면 밖으로 벗어나지 않도록 클램프(옵션)
                let minY = (toastView.bounds.height / 2) + host.safeAreaInsets.top + 8
                let maxY = host.bounds.height - (toastView.bounds.height / 2) - safeBottom - 8
                y = min(max(minY, y), maxY)
                
                let point = CGPoint(x: host.bounds.width / 2, y: y)
                host.showToast(toastView, duration: duration, point: point, completion: completion)
            } else {
                host.showToast(toastView, duration: duration, position: position, completion: completion)
            }
        }
    }
    /// 문자열 메시지 간단 토스트 (중복 제거)
    static func showOnce(message: String,
                         duration: TimeInterval = 2.0,
                         position: ToastPosition = .bottom,
                         allowDuplicate: Bool = false,
                         onDismiss: (() -> Void)? = nil) {
        
        DispatchQueue.main.async {
            guard let host = keyWindow() else { return }
            if !allowDuplicate {
                host.hideAllToasts(includeActivity: true, clearQueue: true)
            }
            host.makeToast(message, duration: duration, position: position) {didTap in 
                onDismiss?()
            }
        }
    }
}
