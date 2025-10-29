//
//  MyListViewController.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/5/25.
//

import UIKit
import Tabman
import Pageboy
import SwinjectStoryboard
import Combine

final class MyListTabViewController: TabmanViewController {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var subscriptions = Set<AnyCancellable>()
    
    private var viewControllers: [UIViewController] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        setupTMbar()
    }
    
    
    private func bind() {
        NotificationCenter.default.publisher(for: .LZSChangeLocaleStringNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.setLocalizedText()
            }.store(in: &subscriptions)
    }
    
    private func setLocalizedText() {
        
    }
    
    private var hidingBar: TMHidingBar!
    
    private func setupTMbar() {
        viewControllers = makeVCs()
        
//        // 데이터 소스 설정
        self.dataSource = self
        
        let bar = TMBar.ButtonBar()
        hidingBar = bar.hiding(trigger: .manual)
        
        bar.backgroundView.style = .clear
        // 간격 설정
        bar.layout.contentInset = UIEdgeInsets(top: 0,
                                               left: 20,
                                               bottom: 0,
                                               right: 20)
//
//        //탭바 레이아웃 설정
//        bar.layout.transitionStyle = .snap
//        bar.layout.alignment = .centerDistributed
//        bar.layout.contentMode = .intrinsic
//        //        .fit : indicator가 버튼크기로 설정됨
//        bar.layout.interButtonSpacing = view.bounds.width / 8
        bar.layout.interButtonSpacing = 20
        
        // 버튼 글씨 커스텀
        bar.buttons.customize { (button) in
            button.tintColor = UIColor(.whiteOpacity35)
            button.selectedTintColor = .white
            button.font = UIFont.pretendardBold(size: 24)
            button.selectedFont = UIFont.pretendardBold(size: 24)
        }
        // 밑줄 쳐지는 부분
        bar.indicator.weight = .custom(value: 2)
        bar.indicator.tintColor = .white
        
        addBar(bar, dataSource: self, at: .top)
        
    }
    
    private func makeVCs() -> [UIViewController] {
        
        guard let watchHistoryListViewController = AppContext.container.resolve(WatchHistoryListViewController.self) else { return [] }
        guard let wishListViewController = AppContext.container.resolve(WishListViewController.self) else { return [] }
        guard let purchasedContentListViewController = AppContext.container.resolve(PurchasedContentListViewController.self) else { return [] }
        
        return [
            watchHistoryListViewController,
            wishListViewController,
            purchasedContentListViewController
        ]
    }
    
    func didTapEditButton(isEditMode: Bool) {
        if isEditMode {
            self.hidingBar.hide(animated: true, completion: nil)
        } else {
            self.hidingBar.show(animated: true, completion: nil)
        }
    }
    
}

extension MyListTabViewController: PageboyViewControllerDataSource, TMBarDataSource {
    
    // Pageboy 데이터 소스 메서드
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil  // 기본 페이지 설정(없으면 첫번째 페이지)
    }
    
    // TMBar 데이터 소스 메서드
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        
        switch index {
        case 0:
            return TMBarItem(title: "내목록_최근시청한_타이틀".localized)
        case 1:
            return TMBarItem(title: "내목록_찜한_타이틀".localized)
        case 2:
            return TMBarItem(title: "내목록_구매한_타이틀".localized)
        default:
            return TMBarItem(title: "")
        }
    }
}
