//
//  CustomerSupportNoticeListViewController.swift
//  LezhinSnack
//
//  Created by lwc on 10/20/25.
//

import UIKit
import SnapKit
import Combine

final class CustomerSupportNoticeListViewController: UIViewController, ChildNavigationBarPresentable {

    let childNavigationBar = ChildNavigationBar()
    private let tableView = UITableView(frame: .zero, style: .plain)

    private let viewModel: CustomerSupportNoticeListViewModel
    private var subscriptions = Set<AnyCancellable>()

    
    init?(viewModel: CustomerSupportNoticeListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        viewModel.fetchNoticeList()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(.backgroundDefault)

        setupChildNavigationBar()
        childNavigationBar.delegate = self
        childNavigationBar.titleLabel.text = "고객지원_공지사항_타이틀".localized

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(childNavigationBar.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }

        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorStyle = .none
        tableView.register(NoticeListCell.self, forCellReuseIdentifier: NoticeListCell.reuseID)
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.cellLayoutMarginsFollowReadableWidth = false  // 큰 화면에서 자동 가로 축소 OFF
        tableView.insetsContentViewsToSafeArea = false          // Safe Area가 셀 컨텐츠에 전파되지 않게
        tableView.directionalLayoutMargins = .zero              // 여분 마진 제거
        tableView.separatorInset = .zero                        // (구분선 안 쓰더라도 기본값 제거)
        

        tableView.addPullToRefresh { [weak self] in
            self?.viewModel.fetchNoticeList()
        }
    }

    private func bind() {
        viewModel.$items
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.refreshControl?.endRefreshing()
                self?.tableView.reloadData()
            }
            .store(in: &subscriptions)

        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] msg in
                guard let self else { return }
                LZSnackToastHelper.showOnce(on: self.view, toast: LZSnackToastView(text: msg), duration: 2.0)
                self.tableView.refreshControl?.endRefreshing()
            }
            .store(in: &subscriptions)
        
        viewModel.$noticeItems
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] item in
                guard let self else { return }
                
                // 상세 화면으로 이동
                if let vc = AppContext.container.resolve(CustomerSupportNoticeDetailViewController.self, argument: item) {
                    navigationController?.pushHidesBottomBarViewController(vc)
                }
            }
            .store(in: &subscriptions)
        
    }
    
    /// 제목 줄 수 기반으로 고정 높이 반환 (1줄: 100, 2줄 이상: 126)
    private func heightForRow(title: String, tableWidth: CGFloat) -> CGFloat {
        // 타이틀 가용 폭: 좌 16 + (chevron 24 + 간격 12 + 우 16) 제외
        let contentWidth = tableWidth - 16 - 24 - 12 - 16
        let font = UIFont.pretendardMedium(size: 16)
        
        let bounding = (title as NSString).boundingRect(
            with: CGSize(width: max(0, contentWidth), height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        
        let lineHeight = ceil(font.lineHeight)
        let lines = Int(ceil(bounding.height / max(1, lineHeight)))
        
        return (lines <= 1) ? 100 : 126
    }
    
}

// MARK: - UITableViewDataSource
extension CustomerSupportNoticeListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoticeListCell.reuseID, for: indexPath) as? NoticeListCell
        else { return UITableViewCell() }

        let item = viewModel.items[indexPath.row]
        cell.configure(item)
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(named: .backgroundDefault)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CustomerSupportNoticeListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = viewModel.items[indexPath.row]
        return heightForRow(title: item.title, tableWidth: tableView.bounds.width)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.items[indexPath.row]
        let noticeId = String(item.noticeId)
        viewModel.fetchNotice(noiceId: noticeId)
    }

}

// MARK: - ChildNavigationBarDelegate
extension CustomerSupportNoticeListViewController: ChildNavigationBarDelegate {
    func childNavigationBarDidTapBack(_ navigationBar: ChildNavigationBar) {
        navigationController?.popViewController(animated: true)
    }
}
