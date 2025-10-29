//
//  MyWalletViewController.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/12/25.
//

import UIKit
import SnapKit
import Combine
import Tabman
import Pageboy



protocol ChildCoinHistoryDelegate: AnyObject {
    
    func changeChargeFilter(_ filter: CoinChargeFilter)
    
    func loadMoreCoinChargesIfNeeded(visibleIndex: Int)
    
    func loadMoreUsageIfNeeded(visibleIndex: Int)
     
    
    func reloadCoinChargeHistory()
    func reloadUsageHistory()
    
    func loadCoinChargeHistory()
    func loadUsageHistory()
}


final class MyCoinViewController: TabmanViewController, ChildNavigationBarPresentable {
    
    
    let viewModel: ChargeHistoryViewModel
    
    var subscriptions = Set<AnyCancellable>()
    
    private var viewControllers: [UIViewController] = []
    private var currentCoinBalance: String = ""
    private var expiringWindowDays: String = ""
    
    init(viewModel: ChargeHistoryViewModel, currentCoinBalance: String, expiringWindowDays: String) {
        self.viewModel = viewModel
        self.currentCoinBalance = currentCoinBalance
        self.expiringWindowDays = expiringWindowDays
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let childNavigationBar = ChildNavigationBar()
    
//    var purchaseHistory: [PurchaseHistoryEntity] = []
//    var coinChargeHistory: [CoinChargeHistoryEntity] = []
    
    // 교체
    var coinChargeHistory: [CoinChargeEntity] = []
    var usageHistory: [CoinUsageEntity] = []
    
    
    lazy var tableView = {
        return UITableView()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
    }
    
    func setupUI() {
        setupChildNavigationBar()
        childNavigationBar.titleLabel.text = "앱바_내코인_타이틀".localized
        childNavigationBar.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        view.backgroundColor = UIColor(.backgroundDefault)
        
        setupTMbar()
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
        bar.layout.contentInset = UIEdgeInsets(top: CGFloat(LZSConstant.NavigationBarHeight),
                                               left: 20,
                                               bottom: 0,
                                               right: 20)
        
        bar.layout.interButtonSpacing = 20
        
        // 버튼 글씨 커스텀
        bar.buttons.customize { (button) in
            button.tintColor = UIColor(.whiteOpacity35)
            button.selectedTintColor = .white
            button.font = UIFont.pretendardSemiBold(size: 16)
            button.selectedFont = UIFont.pretendardSemiBold(size: 16)
        }
        // 밑줄 쳐지는 부분
        bar.indicator.weight = .custom(value: 2)
        bar.indicator.tintColor = .white
        
        addBar(bar, dataSource: self, at: .top)
        
    }
    
    private func makeVCs() -> [UIViewController] {
        
        let rechargeHistoryViewController = RechargeHistoryViewController(currentCoinBalance: currentCoinBalance,
                                                                          expiringWindowDays: expiringWindowDays)
        rechargeHistoryViewController.delegate = self
        
        let usageHistoryViewController = UsageHistoryViewController()
        usageHistoryViewController.delegate = self
        
        return [
            rechargeHistoryViewController,
            usageHistoryViewController
        ]
    }
    
    
    func bind() {
        
        // 충전 내역
//        viewModel.$coinCharges
//            .receive(on: RunLoop.main)
//            .sink { [weak self] items in
//                guard let self, let items else { return }
//                self.coinChargeHistory = items
//                (self.viewControllers[0] as? RechargeHistoryViewController)?
//                    .applySnapshot(items: items)
//            }
//            .store(in: &subscriptions)
        
        viewModel.$coinCharges
            .receive(on: RunLoop.main)
            .sink { [weak self] items in
                guard let self else { return }
                self.coinChargeHistory = items
                if let vc = self.viewControllers[0] as? RechargeHistoryViewController {
                    vc.loadViewIfNeeded()                
                    vc.applySnapshot(items: items)
                }
            }
            .store(in: &subscriptions)
        
        // 사용 내역
        viewModel.$coinUsage
            .receive(on: RunLoop.main)
            .sink { [weak self] items in
                guard let self else { return }
                self.usageHistory = items
                if let vc = self.viewControllers[1] as? UsageHistoryViewController {
                    vc.loadViewIfNeeded()
                    vc.applySnapshot(items: items)
                }
            }
            .store(in: &subscriptions)
        
        // 보유 코인 헤더
        viewModel.$userCoin
            .receive(on: RunLoop.main)
            .sink { [weak self] uc in
                guard let self, let uc else { return }
                if let header = (self.viewControllers[0] as? RechargeHistoryViewController)?
                    .getHeaderView() {
                    let total = uc.coin + uc.bonusCoin
                    header.setCoinInfoViewText(
                        setCoinText: "\(total)",
                        expiredCoinText: "\(uc.expiringCoin)" // 숫자는 만료 예정 코인 수로
                    )
                }
            }
            .store(in: &subscriptions)
    }
    
}

extension MyCoinViewController: PageboyViewControllerDataSource, TMBarDataSource {
    
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
            return TMBarItem(title: "내코인_충전내역_타이틀".localized)
        case 1:
            return TMBarItem(title: "내코인_사용내역_타이틀".localized)
        default:
            return TMBarItem(title: "")
        }
    }
}

extension MyCoinViewController: ChildCoinHistoryDelegate {
    
    func changeChargeFilter(_ filter: CoinChargeFilter) {
        viewModel.reloadCoinCharges(filter: filter)
    }
    
    func loadMoreCoinChargesIfNeeded(visibleIndex: Int) {
        viewModel.fetchNextCoinChargesIfNeeded(visibleIndex: visibleIndex)
    }
    
    func loadMoreUsageIfNeeded(visibleIndex: Int) {
        viewModel.fetchNextCoinUsageIfNeeded(visibleIndex: visibleIndex)
    }
    
    func loadCoinChargeHistory() {
        viewModel.fetchCoinChargeHistory()
        
    }
    func loadUsageHistory() {
        
        viewModel.fetchCoinUsageHistory()
    }
    
    func reloadCoinChargeHistory() {
        viewModel.reloadCoinCharges()
    }
    
    func reloadUsageHistory() {
        viewModel.reloadCoinUsage()
    }
    
}

extension MyCoinViewController: ChildNavigationBarDelegate {
    
    func childNavigationBarDidTapBack(_ navigationBar: ChildNavigationBar) {
        navigationController?.popViewController(animated: true)
    }
    
}


extension MyCoinViewController: UIGestureRecognizerDelegate {
    
}
