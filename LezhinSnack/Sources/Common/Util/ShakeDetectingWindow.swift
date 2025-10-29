//
//  NetworkDebugWindow.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/11/25.
//


import UIKit
import SwiftUI
import PulseUI

final class NetworkDebugWindow: UIWindow {
  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    super.motionEnded(motion, with: event)
    guard motion == .motionShake else { return }
    // 흔들기 감지 시 콘솔 띄우기
    showConsole()
  }

  private func showConsole() {
    // 최상단 뷰컨트롤러 찾기
    guard let topVC = topMostViewController() else { return }
    // SwiftUI ConsoleView를 호스팅하는 VC 생성
    let vc = UIHostingController(rootView: ConsoleView())
    vc.extendedLayoutIncludesOpaqueBars = true
    let nav = UINavigationController(rootViewController: vc)
    nav.navigationBar.prefersLargeTitles = true
    topVC.present(nav, animated: true)
  }

  private func topMostViewController(base: UIViewController? = UIApplication.shared.connectedScenes
                                      .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                                      .first?.rootViewController) -> UIViewController? {
    if let nav = base as? UINavigationController {
      return topMostViewController(base: nav.visibleViewController)
    }
    if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
      return topMostViewController(base: selected)
    }
    if let presented = base?.presentedViewController {
      return topMostViewController(base: presented)
    }
    return base
  }
}
