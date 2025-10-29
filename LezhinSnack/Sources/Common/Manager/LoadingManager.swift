//
//  LoadingManager.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/2/25.
//

import UIKit
import SnapKit

final class LoadingManager {
    static let shared = LoadingManager()
    private var loadingView: LZSnackLoadingView?
    private let lockQueue = DispatchQueue(label: "com.lezhinsnack.loadingmanager.queue")

    private init() {}


    // ① 윈도우 전체를 덮기 (파라미터 없이 호출)
    func show() {
        lockQueue.async { [weak self] in
            guard let self = self, self.loadingView == nil else { return }
            DispatchQueue.main.async {
                // 현재 활성화된 씬의 키 윈도우 찾기
                guard let windowScene = UIApplication.shared.connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .first(where: { $0.activationState == .foregroundActive }),
                      let window = windowScene.windows.first(where: { $0.isKeyWindow })
                else { return }

                // 윈도우 전체를 덮는 로딩뷰 생성
                let loading = LZSnackLoadingView(frame: window.bounds)
                loading.startAnimating()
                loading.translatesAutoresizingMaskIntoConstraints = false

                window.addSubview(loading)
                loading.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }

                self.loadingView = loading
            }
        }
    }

    // ② 특정 ViewController 위에 띄우기
    func show(on viewController: UIViewController) {
        lockQueue.async { [weak self] in
            guard let self = self, self.loadingView == nil else { return }
            DispatchQueue.main.async {
                let loading = LZSnackLoadingView(frame: viewController.view.bounds)
                loading.startAnimating()
                loading.translatesAutoresizingMaskIntoConstraints = false

                viewController.view.addSubview(loading)
                loading.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }

                self.loadingView = loading
            }
        }
    }

    // ③ 특정 UIView 위에만 띄우기
    func show(on view: UIView) {
        lockQueue.async { [weak self] in
            guard let self = self, self.loadingView == nil else { return }
            DispatchQueue.main.async {
                let loading = LZSnackLoadingView(frame: view.bounds)
                loading.startAnimating()
                loading.translatesAutoresizingMaskIntoConstraints = false

                view.addSubview(loading)
                loading.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }

                self.loadingView = loading
            }
        }
    }

    // 데이터를 로드한 뒤 또는 작업 끝난 후 호출
    func hide() {
        lockQueue.async { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.loadingView?.stopAnimating()
                self.loadingView?.removeFromSuperview()
                self.loadingView = nil
            }
        }
    }

    /// 최상위(Topmost) ViewController를 탐색하는 헬퍼 메소드
    private func topMostViewController(base: UIViewController? = UIApplication.shared.connectedScenes
                                                    .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                                                    .first?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topMostViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topMostViewController(base: presented)
        }
        return base
    }
}
