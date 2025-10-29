//
//  TabBarViewController.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/5/25.
//

import UIKit
import SwinjectStoryboard
import SwiftyUserDefaults
import Combine
import Lottie
import SnapKit

final class TabBarViewController: UITabBarController {
    
    private var didSetupCustomTabs = false
    private var snackAnimationView: LottieAnimationView?
    
    private var viewControllerList: [UIViewController]?
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var homeCoordinator: HomeCoordinator?
    
    private enum TabType: Int, CaseIterable {
        case home = 0, recommended, playlist, profile

        var defaultIcon: UIImage? {
            switch self {
            case .home:      return UIImage(named: "ic_home_desel")?.withRenderingMode(.alwaysOriginal)
            case .recommended:     return UIImage(named: "ic_snack_desel")?.withRenderingMode(.alwaysOriginal)
            case .playlist:  return UIImage(named: "ic_inventory_desel")?.withRenderingMode(.alwaysOriginal)
            case .profile:   return UIImage(named: "ic_user_desel")?.withRenderingMode(.alwaysOriginal)
            }
        }

        var selectedIcon: UIImage? {
            switch self {
            case .home:      return UIImage(named: "ic_home_sel")?.withRenderingMode(.alwaysOriginal)
            case .recommended:     return UIImage(named: "ic_snack_sel")?.withRenderingMode(.alwaysOriginal)
            case .playlist:  return UIImage(named: "ic_inventory_sel")?.withRenderingMode(.alwaysOriginal)
            case .profile:   return UIImage(named: "ic_user_sel")?.withRenderingMode(.alwaysOriginal)
            }
        }

        var title: String {
            switch self {
            case .home:             return "탭바_홈".localized
            case .recommended:      return "탭바_맛보기".localized
            case .playlist:         return "탭바_내목록".localized
            case .profile:          return "탭바_마이".localized
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        if #available(iOS 18.0, *) {
            if UIDevice.current.userInterfaceIdiom == .pad {
                traitOverrides.horizontalSizeClass = .compact
            }
        }
        
        view.backgroundColor = UIColor(.backgroundRaisedDefault)
        
        super.tabBar.isTranslucent = false
        super.tabBar.tintAdjustmentMode = .normal
        
        setTabBarList()
        self.viewControllers = viewControllerList
        setTabBarAppearance()
        
        
        bind()
        
        setupCustomTabItems()
        
        let testString = String(localized: "탭바_마이")
        printX("런타임 언어 변경 테스트: " + testString,isBoxMode: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 원하는 높이
        let fixedHeight: CGFloat = 71 + ( LZSUtil.getSafeAreaInsets().bottom / 2 )
        // 탭바 현재 프레임
        var tabFrame = tabBar.frame
        // 높이만 바꿔주고
        tabFrame.size.height = fixedHeight
        // Y 위치를 화면 맨 아래로 다시 설정
        tabFrame.origin.y = view.bounds.height - fixedHeight
        tabBar.frame = tabFrame
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Defaults.isShowPermissionPopup == false {
            onMain {
                let popup = LZSnackAppPermissionPopup(
                    width: 320,
                    height: 442,
                    buttonTitle: "확인",
                    handler: {
                        Defaults.isShowPermissionPopup = true
                        AppContext.shared.requestPushNotificationPermissions()
                    }
                )
                popup.show()
            }
        }
        
        handlePendingPushNavigation()
        
    }
    
    
    private func bind() {
        NotificationCenter.default.publisher(for: .LZSForegroundPushReceiveNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] notificationObject in
                guard let pushInfo = notificationObject.object else { return }
                printX(pushInfo,isBoxMode: true)
                
                guard let vc = AppContext.container.resolve(InAppPurchaseViewController.self) else { return }
                guard let selectedViewController = self?.selectedViewController as? UINavigationController else { return }
                selectedViewController.pushViewController(vc, animated: true)
                
            }.store(in: &subscriptions)
    }
    
    private func handlePendingPushNavigation() {
        if Defaults.pendingPushDict != nil {
            guard let vc = AppContext.container.resolve(InAppPurchaseViewController.self) else {
                Defaults.pendingPushDict = nil
                return }
            
            
            guard let selectedViewController = selectedViewController as? UINavigationController else { return }
            selectedViewController.pushViewController(vc, animated: true)
            
            Defaults.pendingPushDict = nil
        }
    }
    
    private func setupCustomTabItems() {
        let controls = tabBar.subviews
            .compactMap { $0 as? UIControl }
            .sorted { $0.frame.minX < $1.frame.minX }

        // 1) 모든 탭에 아이콘+레이블 추가
        for (index, tab) in TabType.allCases.enumerated() {
            guard index < controls.count else { continue }
            addIconAndLabel(to: controls[index], for: tab)
        }

        // 2) 추천 탭에만 Lottie 뷰 추가 (아이콘·레이블 위에 덧씌우기)
        if let recControl = controls[safe: TabType.recommended.rawValue] {
            addSnackLottie(to: recControl)
            // ensure top
            if let animView = recControl.viewWithTag(102) {
                recControl.bringSubviewToFront(animView)
            }
        }

        // 3) 초기 선택 상태 설정
        updateTabSelectionAppearance()
    }
    
    private func addIconAndLabel(to control: UIControl, for tab: TabType) {
        let icon = UIImageView(image: tab.defaultIcon)
        icon.tag = 100
        icon.contentMode = .scaleAspectFit
        control.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.size.equalTo(24)
        }

        let label = UILabel()
        label.tag = 101
        label.text = tab.title
        label.font = .pretendardSemiBold(size: 11)
        label.textAlignment = .center
        control.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.height.equalTo(15)
        }
    }

    private func addSnackLottie(to control: UIControl) {
//        let animationView = LottieAnimationView(name: "ic_tasting_lottie_label_3-1")
        let animationView = LottieAnimationView(name: "ic_tasting_lottie")
        animationView.tag = 102
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.isUserInteractionEnabled = false
        control.addSubview(animationView)
        control.backgroundColor = .clear
        control.bringSubviewToFront(animationView)
        animationView.backgroundColor = .clear
        animationView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.size.equalTo(54)
        }
        snackAnimationView = animationView

        // Play only once on launch
        animationView.play { [weak self] _ in
            animationView.removeFromSuperview()
            self?.snackAnimationView = nil
            self?.updateTabSelectionAppearance()
        }
    }
    
    func updateTabSelectionAppearance() {
        let controls = tabBar.subviews.compactMap { $0 as? UIControl }
            .sorted { $0.frame.minX < $1.frame.minX }

        for (index, tab) in TabType.allCases.enumerated() {
            guard index < controls.count else { continue }
            let control = controls[index]
            let selected = (selectedIndex == index)

            // Icon
            if let icon = control.viewWithTag(100) as? UIImageView {
                icon.image = selected ? tab.selectedIcon : tab.defaultIcon
                icon.isHidden = false
            }
            // Label
            if let label = control.viewWithTag(101) as? UILabel {
                label.textColor = selected ? .white : .whiteOpacity35
                label.isHidden = false
            }
        }
    }

    
    private func setTabBarAppearance() {
        let appearance = UITabBarAppearance()
        // 기본 불투명 배경 세팅 (투명하게 쓰려면 configureWithTransparentBackground())
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(.backgroundRaisedDefault)
        
        // 그림자 제거
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()        // (선택) 그림자 이미지를 빈 이미지로 교체
        
        // 배경 이미지도 빈 이미지로 교체
        appearance.backgroundImage = UIImage()
        
        // 표준·스크롤 엣지 모두 동일한 appearance 적용
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    private func setTabBarList() {
        viewControllerList = [
            makeHomeVC(),
            makeRecommendVC(),
            makeMyListVC(),
            makeProfileVC()
        ].compactMap { $0 }
    }
    
    private func makeHomeVC() -> UINavigationController {
        // 1) VC DI
        guard let homeVC = AppContext.container.resolve(HomeViewController.self) else {
            return UINavigationController()
        }
        
        // 2) 네비 컨테이너
        let nvc = UINavigationController(rootViewController: homeVC)
        nvc.tabBarItem = UITabBarItem(title: "", image: nil, selectedImage: nil)
        nvc.isNavigationBarHidden = true
        
        // 3) 코디네이터 DI + 바인딩
        let interactor = AppContext.container.resolve(HomeViewerPrefetchInteractor.self)!
        let coordinator = HomeCoordinator(navigation: nvc, interactor: interactor)
        
        // AppCoordinator가 강하게 보관 (VC 쪽은 weak로 권장)
        self.homeCoordinator = coordinator
        
        // HomeVC에 코디네이터 연결 (내부에서 viewModel 바인딩)
        homeVC.attachCoordinator(coordinator)
        
        return nvc
    }
//        guard let homeVC = AppContext.container.resolve(HomeViewController.self) else { return UINavigationController() }
//        let nvc = UINavigationController(rootViewController: homeVC)
//        nvc.tabBarItem = UITabBarItem(
//            title: "",
//            image: nil,
//            selectedImage: nil
//        )
//        nvc.isNavigationBarHidden = true
//        return nvc
//    }

    private func makeRecommendVC() -> UINavigationController {
        guard let recommendVC = AppContext.container.resolve(ViewerViewController.self,
                                                             argument: ViewerRoute.tasted) else { return UINavigationController() }
        let nvc = UINavigationController(rootViewController: recommendVC)
        nvc.tabBarItem = UITabBarItem( title: "", image: nil, selectedImage: nil )
        nvc.isNavigationBarHidden = true
        return nvc
    }

    private func makeMyListVC() -> UINavigationController {
        
        guard let myListVC = AppContext.container.resolve(MyListTabViewController.self) else { return UINavigationController() }
        
        let nvc = UINavigationController(rootViewController: myListVC)
        nvc.tabBarItem = UITabBarItem( title: "", image: nil, selectedImage: nil )
        nvc.isNavigationBarHidden = true
        return nvc
    }

    private func makeProfileVC() -> UINavigationController {
//        let storyboard = SwinjectStoryboard.create(name: "MyProfileViewController", bundle: nil)
//        guard let profileVC = storyboard.instantiateViewController(withIdentifier: "MyProfileViewController") as? MyProfileViewController else {
//            fatalError("MyProfileViewController를 찾을 수 없습니다.")
//        }
        
        guard let mypageVC = AppContext.container.resolve(MyPageViewController.self) else { return UINavigationController() }
        
        let nvc = UINavigationController(rootViewController: mypageVC)
        nvc.tabBarItem = UITabBarItem( title: "", image: nil, selectedImage: nil )
        nvc.isNavigationBarHidden = true
        return nvc
    }

}

extension TabBarViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let nextIndex = viewControllers?.firstIndex(of: viewController) ?? 0
        // if snack tab tapped during animation, remove anim immediately
        if nextIndex == TabType.recommended.rawValue, let anim = snackAnimationView {
            anim.removeFromSuperview()
            snackAnimationView = nil
        }
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {
        guard let selectedTab = TabType(rawValue: tabBarController.selectedIndex) else { return }
        
        switch selectedTab {
        case .home:
            // Home 탭이 선택된 경우
            if let nav = viewController as? UINavigationController,
               let homeVC = nav.topViewController as? HomeViewController {
                print("▶️ Home 탭이 선택되었습니다.")
            }
            
        case .recommended:
            // Recommended 탭이 선택된 경우
            if let nav = viewController as? UINavigationController,
               let recVC = nav.topViewController as? ViewerViewController {
                print("▶️ RViewerView 탭이 선택되었습니다.")
            }
            
        case .playlist:
            // Playlist 탭이 선택된 경우
            if let nav = viewController as? UINavigationController,
               let listVC = nav.topViewController as? MyListTabViewController {
                
                print("▶️ MyListTab 탭이 선택되었습니다.")
            }
            
        case .profile:
            // Profile 탭이 선택된 경우
            if let nav = viewController as? UINavigationController,
               let myPageVC = nav.topViewController as? MyPageViewController {
                print("▶️ Profile 탭(마이페이지)이 선택되었습니다.")
                
            }
        }
        updateTabSelectionAppearance()
    }
}

// MARK: - UIImageView 탐색 헬퍼
private extension UIView {
    func findFirstImageView() -> UIImageView? {
        if let iv = self as? UIImageView { return iv }
        for sub in subviews {
            if let iv = sub.findFirstImageView() { return iv }
        }
        return nil
    }
}
