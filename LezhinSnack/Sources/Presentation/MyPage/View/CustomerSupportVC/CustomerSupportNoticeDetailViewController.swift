//
//  CustomerSupportNoticeDetailViewController.swift
//  LezhinSnack
//
//  Created by lwc on 10/20/25.
//

import UIKit
import SnapKit
import WebKit

final class CustomerSupportNoticeDetailViewController: UIViewController, ChildNavigationBarPresentable {

    private var entity: NoticeEntity?
    convenience init?(entity: NoticeEntity) {
        self.init(nibName: nil, bundle: nil)
        self.entity = entity
    }

    // 혹시 푸시 이후에도 바꿔 끼우고 싶을 때 사용
    func configure(entity: NoticeEntity) {
        self.entity = entity
        if isViewLoaded { applyEntity() }
    }

    // MARK: - UI
    let childNavigationBar = ChildNavigationBar()

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let htmlView      = LZSnackHTMLView()
    private var htmlHeight: Constraint?
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.16, alpha: 1)
        return view
    }()
    
    
    private let categoryLabel: UILabel = {
        let lb = UILabel()
        lb.font = .pretendardRegular(size: 14)
        lb.textColor = UIColor(.foregroundBrand)
        lb.numberOfLines = 1
        return lb
    }()

    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.font = .pretendardMedium(size: 20)
        lb.textColor = .white
        lb.numberOfLines = 0
        return lb
    }()

    private let dateLabel: UILabel = {
        let lb = UILabel()
        lb.font = .pretendardRegular(size: 13)
        lb.textColor = UIColor(.foregroundSubtler)
        return lb
    }()
    
    private let listButton = LZSnackPrimaryButton(
        title: "목록보기",
        fontSize: 16
    )

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        applyEntity()
    }

    // MARK: - UI
    private func setupUI() {
        view.backgroundColor = UIColor(.backgroundDefault)

        // 네비게이션 바
        setupChildNavigationBar()
        childNavigationBar.delegate = self
        childNavigationBar.titleLabel.text = "고객지원_공지사항_타이틀".localized

        // 목록 버튼
        view.addSubview(listButton)
        listButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(56)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
        listButton.addTarget(self, action: #selector(tapList), for: .touchUpInside)

        // 스크롤 영역 (스택뷰 사용 금지 조건에 맞춰 수동 배치)
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(childNavigationBar.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(listButton.snp.top).offset(-16) // 버튼 위까지
        }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide) // 폭 고정(가로 흔들림 방지)
        }
        
        // 요소들 수동 배치
        contentView.addSubview(categoryLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(lineView)
        
        contentView.addSubview(htmlView)

        categoryLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        lineView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.top.equalTo(dateLabel.snp.bottom).offset(12)
            make.trailing.trailing.equalToSuperview().inset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        htmlView.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            htmlHeight = make.height.equalTo(1).constraint
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        // HTML 로드(상대경로 리소스가 있으면 baseURL 넣기)
        htmlView.load(html: self.entity?.contents ?? "", baseURL: URL(string: AppContext.shared.baseNewApiUrl))
        htmlView.onHeightChange = { [weak self] h in
            self?.htmlHeight?.update(offset: h)
        }
        
    }

    private func applyEntity() {
        guard let itme = entity, isViewLoaded else { return }
        categoryLabel.text = itme.categoryTitle
        titleLabel.text = itme.title
        dateLabel.text = format(itme.postedAt)
    }

    // MARK: - Actions
    @objc private func tapList() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Helpers
    private func format(_ ms: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(ms) / 1000.0)
        let f = DateFormatter()
        f.locale = .current
        f.timeZone = .current
        f.dateFormat = "yyyy.MM.dd"
        return f.string(from: date)
    }
}

// MARK: - ChildNavigationBarDelegate
extension CustomerSupportNoticeDetailViewController: ChildNavigationBarDelegate {
    func childNavigationBarDidTapBack(_ navigationBar: ChildNavigationBar) {
        navigationController?.popViewController(animated: true)
    }
}
