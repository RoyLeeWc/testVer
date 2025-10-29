//
//  CustomerSupportFAQListViewController.swift
//  LezhinSnack
//
//  Created by lwc on 10/20/25.
//

import UIKit
import SnapKit
import Combine
import Tabman
import Pageboy

final class CustomerSupportFAQCategoryViewController: TabmanViewController, ChildNavigationBarPresentable {

    private let categories: [FaqCategoryEntity]
    private let faqs: [FaqEntity]  // ✅ 전체 FAQ

    let childNavigationBar = ChildNavigationBar()
    private var bar: TMBar.ButtonBar!
    private var hidingBar: TMHidingBar!
    private var pages: [UIViewController] = []

    // DI로 생성
    init?(categories: [FaqCategoryEntity], faqs: [FaqEntity]) {
        self.categories = categories
        self.faqs = faqs
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        buildPages()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(.backgroundDefault)
        setupChildNavigationBar()
        childNavigationBar.delegate = self
        childNavigationBar.titleLabel.text = "고객지원_FAQ_타이틀".localized

        // Tabman bar
        let bar = TMBar.ButtonBar()
        hidingBar = bar.hiding(trigger: .manual)
        bar.backgroundView.style = .clear
        bar.layout.contentInset = UIEdgeInsets(top: CGFloat(LZSConstant.NavigationBarHeight), left: 20, bottom: 0, right: 20)
        bar.layout.interButtonSpacing = 20
        bar.buttons.customize {
            $0.tintColor = UIColor(.whiteOpacity35)
            $0.selectedTintColor = .white
            $0.font = .pretendardSemiBold(size: 16)
            $0.selectedFont = .pretendardSemiBold(size: 16)
        }
        bar.indicator.weight = .custom(value: 2)
        bar.indicator.tintColor = .white

        self.bar = bar
        addBar(bar, dataSource: self, at: .top)
    }

    private func buildPages() {
        // 카테고리별로 미리받은 전체 FAQ에서 필터 → 각 페이지 VC에 주입 (네트워크 X)
        pages = categories.map { cat in
            let items = faqs.filter { $0.categoryId == cat.categoryId }
            // VC/VM DI는 AppContext에서 처리
            return AppContext.container.resolve(CustomerSupportFAQListViewController.self,
                                                arguments: items, cat.name)!
        }
        dataSource = self
        reloadData()
    }
}

extension CustomerSupportFAQCategoryViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int { pages.count }
    func viewController(for pageboyViewController: PageboyViewController, at index: Int) -> UIViewController? { pages[index] }
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? { nil }
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable { TMBarItem(title: categories[index].name) }
}

extension CustomerSupportFAQCategoryViewController: ChildNavigationBarDelegate {
    func childNavigationBarDidTapBack(_ navigationBar: ChildNavigationBar) {
        navigationController?.popViewController(animated: true)
    }
}
