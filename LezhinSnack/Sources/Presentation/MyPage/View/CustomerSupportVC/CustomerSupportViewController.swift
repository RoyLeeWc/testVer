//
//  CustomerSupportViewController.swift
//  LezhinSnack
//
//  Created by lwc on 10/17/25.
//

import UIKit
import SnapKit
import Combine

/// 고객지원: 공지사항 / FAQ / 1:1 문의 목록 진입 전 메뉴
final class CustomerSupportViewController: UIViewController, ChildNavigationBarPresentable {
    
    // 네비게이션 바 (SettingViewController와 동일 스타일)
    let childNavigationBar = ChildNavigationBar()
    
    private let viewModel: CustomerSupportViewModel
    private var subscriptions = Set<AnyCancellable>()
    private var shouldNavigateToFAQ = false   // 탭 후에만 이동
    
    init?(viewModel: CustomerSupportViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // 공통 한 줄 UI 스타일을 재사용하기 위해 래퍼를 만든다.
    private func makeRow(title: String, action: Selector) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        container.isUserInteractionEnabled = true
        
        let titleLabel = UILabel()
        titleLabel.font = .pretendardMedium(size: 16)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
        titleLabel.text = title
        
        let chevron = UIImageView(image: UIImage(named: "ic_chevron_right_white"))
        chevron.contentMode = .scaleAspectFit
        
        container.addSubview(titleLabel)
        container.addSubview(chevron)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        chevron.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        // 탭 제스처 연결
        let tap = UITapGestureRecognizer(target: self, action: action)
        container.addGestureRecognizer(tap)
        container.snp.makeConstraints { make in
            make.height.equalTo(58) // language row와 동일 높이
        }

        return container
    }
    
    private lazy var noticeRow = makeRow(title: "고객지원_공지사항_타이틀".localized, action: #selector(tappedNotice))
    private lazy var faqRow    = makeRow(title: "고객지원_FAQ_타이틀".localized,      action: #selector(tappedFAQ))
    private lazy var oneToOneRow = makeRow(title: "고객지원_1:1문의_타이틀".localized, action: #selector(tappedOneToOne))
    
    // 스택으로 3개를 수직 배치
    private let stack = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    private func bind() {
        Publishers.CombineLatest(viewModel.$items, viewModel.$faqs)
            .receive(on: RunLoop.main)
            .filter { [weak self] _ in self?.shouldNavigateToFAQ == true }
            .filter { !$0.0.isEmpty && !$0.1.isEmpty }
            .sink { [weak self] (categories, allFaqs) in
                guard let self else { return }
                self.shouldNavigateToFAQ = false
                if let vc = AppContext.container.resolve(
                    CustomerSupportFAQCategoryViewController.self,
                    arguments: categories, allFaqs
                ) {
                    self.navigationController?.pushHidesBottomBarViewController(vc)
                }
            }
            .store(in: &subscriptions)

        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] msg in
                guard let self else { return }
                
                
            }
            .store(in: &subscriptions)
    }
}

// MARK: - UI
extension CustomerSupportViewController {
    private func setupUI() {
        view.backgroundColor = UIColor(.backgroundDefault)
        
        // 네비게이션 바
        setupChildNavigationBar()
        childNavigationBar.delegate = self
        childNavigationBar.titleLabel.text = "앱바_고객지원_타이틀".localized
        
        // 스택
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 0
        
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(childNavigationBar.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
        }
        
        // 항목 추가
        stack.addArrangedSubview(noticeRow)
        stack.addArrangedSubview(faqRow)
        stack.addArrangedSubview(oneToOneRow)
    }
}

// MARK: - Actions
extension CustomerSupportViewController {
    @objc private func tappedNotice() {
        print("공지사항")
        // 공지사항 목록 화면으로 이동
        if let vc = AppContext.container.resolve(CustomerSupportNoticeListViewController.self) {
            navigationController?.pushHidesBottomBarViewController(vc)
        }
    }
 
    @objc private func tappedFAQ() {
        print("faq")
        // FAQ 화면으로 이동
        shouldNavigateToFAQ = true
        viewModel.fetchFAQStartup()
    }
    
    @objc private func tappedOneToOne() {
        print("1eo1")
        // 1:1 문의 목록(또는 작성) 화면으로 이동
//        if let vc = AppContext.container.resolve(InquiryListViewController.self) {
//            navigationController?.pushHidesBottomBarViewController(vc)
//        }
    }
}

// MARK: - ChildNavigationBarDelegate
extension CustomerSupportViewController: ChildNavigationBarDelegate {
    func childNavigationBarDidTapBack(_ navigationBar: ChildNavigationBar) {
        navigationController?.popViewController(animated: true)
    }
}
