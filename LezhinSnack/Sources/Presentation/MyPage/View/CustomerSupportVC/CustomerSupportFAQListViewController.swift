//
//  CustomerSupportFAQListByCategoryViewController.swift
//  LezhinSnack
//
//  Created by lwc on 10/20/25.
//

// CustomerSupportFAQListViewController.swift (카테고리별 목록)
import UIKit
import SnapKit
import Combine

final class CustomerSupportFAQListViewController: UIViewController {

    private let viewModel: CustomerSupportFAQListViewModel
    private let categoryName: String
    private var tableView = UITableView(frame: .zero, style: .plain)
    private var subscriptions = Set<AnyCancellable>()

    init?(viewModel: CustomerSupportFAQListViewModel, categoryName: String) {
        self.viewModel = viewModel
        self.categoryName = categoryName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        
    }

    private func setupUI() {
        view.backgroundColor = UIColor(.backgroundDefault)
        view.addSubview(tableView)


        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 68
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.insetsContentViewsToSafeArea = false
        tableView.directionalLayoutMargins = .zero

        tableView.register(FAQListCell.self, forCellReuseIdentifier: FAQListCell.reuseID)
        tableView.dataSource = self
        tableView.delegate   = self
    }

    private func bind() {
        // items는 이미 세팅되어 있으니 단순 리로드
        viewModel.$items
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.tableView.reloadData() }
            .store(in: &subscriptions)
    }
}

extension CustomerSupportFAQListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.items.count
    }
    
    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tv.dequeueReusableCell(withIdentifier: FAQListCell.reuseID, for: indexPath) as? FAQListCell else { return UITableViewCell() }
        cell.configure(question: viewModel.items[indexPath.row].question)
        return cell
    }

    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.items[indexPath.row]

        if let vc = AppContext.container.resolve(CustomerSupportFAQDetailViewController.self, argument: item.faqId) {
            navigationController?.pushHidesBottomBarViewController(vc)
        }
    }

}
