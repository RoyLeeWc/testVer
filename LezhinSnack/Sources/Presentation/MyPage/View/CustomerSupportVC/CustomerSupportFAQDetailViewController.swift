//
//  CustomerSupportFAQDetailViewController.swift
//  LezhinSnack
//
//  Created by lwc on 10/21/25.
//

import UIKit
import SnapKit
import WebKit
import Combine

final class CustomerSupportFAQDetailViewController: UIViewController, ChildNavigationBarPresentable {

    private let viewModel: CustomerSupportFAQDetailViewModel
    init?(viewModel: CustomerSupportFAQDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI
    let childNavigationBar = ChildNavigationBar()

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let htmlView = LZSnackHTMLView()
    private var htmlHeight: Constraint?

    private var bag = Set<AnyCancellable>()
    
    private let lineView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.16, alpha: 1)
        return v
    }()

    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.font = .pretendardMedium(size: 20)
        lb.textColor = .white
        lb.numberOfLines = 0
        return lb
    }()

    private let listButton = LZSnackPrimaryButton(title: "목록보기", fontSize: 16)

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        viewModel.fetch()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(.backgroundDefault)

        // 네비게이션 바
        setupChildNavigationBar()
        childNavigationBar.delegate = self
        childNavigationBar.titleLabel.text = "고객지원_FAQ_타이틀".localized

        // 하단 버튼
        view.addSubview(listButton)
        listButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(56)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
        listButton.addTarget(self, action: #selector(tapList), for: .touchUpInside)

        // 스크롤
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(childNavigationBar.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(listButton.snp.top).offset(-16)
        }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide) // 가로 고정
        }

        // 콘텐츠
      
        contentView.addSubview(titleLabel)
        contentView.addSubview(lineView)
        contentView.addSubview(htmlView)

 

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        // FAQ는 날짜 미노출: 구분선은 title 아래로 바로
        lineView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        htmlView.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            htmlHeight = make.height.equalTo(1).constraint
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(16)
        }

        // HTML 컨텐츠 높이 반영
        htmlView.onHeightChange = { [weak self] h in
            self?.htmlHeight?.update(offset: h)
        }
    }

    private func bind() {
        viewModel.$item
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] ent in
                self?.apply(ent)
            }
            .store(in: &bag)
        
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] msg in
                guard let self else { return }
                LZSnackToastHelper.showOnce(on: self.view, toast: LZSnackToastView(text: msg), duration: 2.0)
            }
            .store(in: &bag)
    }
    

    private func apply(_ entity: FaqDetailEntity) {
      
        titleLabel.text = entity.question
        htmlView.load(html: entity.answer, baseURL: URL(string: AppContext.shared.baseNewApiUrl))
    }

    @objc private func tapList() {
        navigationController?.popViewController(animated: true)
    }
}

extension CustomerSupportFAQDetailViewController: ChildNavigationBarDelegate {
    func childNavigationBarDidTapBack(_ navigationBar: ChildNavigationBar) {
        navigationController?.popViewController(animated: true)
    }
}
