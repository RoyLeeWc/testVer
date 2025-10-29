//
//  MyPageViewController.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/19/25.
//



import UIKit
import SnapKit
import Combine
import SwiftyUserDefaults

final class MyPageViewController: UIViewController, TitleRootNavigationBarPresentable {
    
    private enum MenuType: Int, CaseIterable {
        case paymentHistory        = 0  // 결제내역
        case myInquiries           = 1  // 내 문의
        case customerSupport       = 2  // 고객지원
        case termsOfService        = 3  // 이용약관
        case settings              = 4  // 설정
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    private let viewModel: MyPageViewModel
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init?(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let rootNavigationBar = TitleRootNavigationBar()
    
    // 스크롤 뷰
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    
    // 유저타입 뷰
    private let userTypeContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 24)
        label.textColor = .white
        return label
    }()
    
    private let userLoginTypeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let userEmailLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 14)
        label.textColor = .foregroundSubtler
        return label
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("마이_로그인_버튼_타이틀".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .pretendardSemiBold(size: 13)
        button.layer.cornerRadius = 4
        button.backgroundColor = .backgroundDefault
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        
        // 1. 경계선 두께
        button.layer.borderWidth = 1
        // 2. 경계선 색상 (예: 연한 회색)
        button.layer.borderColor = UIColor(.borderDefault).cgColor
        
        return button
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("마이_로그아웃_버튼_타이틀".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .pretendardSemiBold(size: 16)
        button.layer.cornerRadius = 4
        button.backgroundColor = UIColor(.fillSubtler100)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        
        return button
    }()
    
    
    // 코인정보 뷰
    private let coinInfoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundRaisedHigh
        return view
    }()
    
    private let innerCoinInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let myCoinLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 16)
        label.textColor = .white
        return label
    }()
    
    private let myCoinIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ic_chevron_right_white"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let coinBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = .borderDefault
        return view
    }()
    
    private let coinImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ic_coin"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let currentTotalCoinLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 24)
        label.textColor = .white
        label.text = "0"
        label.numberOfLines = 0
        return label
    }()
    
    private let coinChargeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("마이_충전하기_버튼_타이틀".localized, for: .normal)
        button.setTitleColor(.backgroundDefault, for: .normal)
        button.titleLabel?.font = .pretendardSemiBold(size: 13)
        button.layer.cornerRadius = 4
        button.backgroundColor = .white
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        return button
    }()
    
    
    private let currentCoinDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 13)
        label.textColor = .white
        return label
    }()
    
    
    
    // 멤버십 상태 관련 뷰
    private let membershipContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    
    // 하단 메뉴뷰
    private let menuStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0                  // 각 메뉴 간 12pt 간격
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
        fetchData()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupMembershipView()
    }
    
    private func setupUI() {
        
        view.backgroundColor = .backgroundDefault
        
        setupRootNavigationBar()
        rootNavigationBar.delegate = self
        rootNavigationBar.setupTitleText("앱바_마이_타이틀".localized)
        
        // 3. 뷰 계층 구성
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 4. SnapKit 제약 설정
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(rootNavigationBar.snp.bottom)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        // contentView는 scrollView의 contentLayoutGuide에 맞춘다
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)   // 스크롤 콘텐츠 전체
            make.width.equalTo(scrollView.frameLayoutGuide)     // 가로는 스크롤 뷰 너비와 같게
        }
        
        setupUserTypeView()
        setUserInfoText()
        setupCoinInfoView()
        setupMembershipView()
        setupMenuStackView()
        
        
        contentView.addSubview(logoutButton)
        logoutButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(menuStackView.snp.bottom).offset(24)
            make.bottom.equalToSuperview().offset(-24)
            make.height.equalTo(48)
        }
        
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        scrollView.addPullToRefresh() { [weak self] in
            self?.fetchData()
        }
    }
    
    private func fetchData() {
        viewModel.fetchUserCoinBalance()
    }
    
    private func setupUserTypeView() {
        contentView.addSubview(userTypeContainerView)
        userTypeContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(58)
        }
        
        userTypeContainerView.addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.height.equalTo(34)
        }
        
        
        userTypeContainerView.addSubview(userLoginTypeImageView)
        userLoginTypeImageView.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview()
            make.width.height.equalTo(16)
        }
        
        userTypeContainerView.addSubview(userEmailLabel)
        userEmailLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom).offset(4)
            make.leading.equalTo(userLoginTypeImageView.snp.trailing)
            make.centerY.equalTo(userLoginTypeImageView.snp.centerY)
        }
        
        userTypeContainerView.addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.height.equalTo(34)
        }
        
        loginButton.addTarget(self, action: #selector(loginButtonOnTapped), for: .touchUpInside)
    }
    
    @objc func loginButtonOnTapped(_ sender: Any) {
        guard let vc = AppContext.container.resolve(UserAuthViewController.self) else { return }
        navigationController?.pushHidesBottomBarViewController(vc)
    }
    
    @objc func logoutButtonTapped(_ sender: Any) {
        viewModel.requestLogout()
    }
    
    private func setupCoinInfoView() {
        contentView.addSubview(coinInfoContainerView)
        coinInfoContainerView.snp.makeConstraints { make in
            make.top.equalTo(userTypeContainerView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(134)
        }
        coinInfoContainerView.roundCorners(cornerRadius: 8)
        
        
        coinInfoContainerView.addSubview(innerCoinInfoView)
        innerCoinInfoView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(32)
        }
        
        innerCoinInfoView.addSubview(myCoinLabel)
        myCoinLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.height.equalTo(22)
        }
        myCoinLabel.text = "마이_내코인_타이틀".localized
        
        innerCoinInfoView.addSubview(myCoinIconImageView)
        myCoinIconImageView.snp.makeConstraints { make in
            make.leading.equalTo(myCoinLabel.snp.trailing).offset(4)
            make.centerY.equalTo(myCoinLabel.snp.centerY)
        }
        
        coinInfoContainerView.addSubview(coinBorderView)
        coinBorderView.snp.makeConstraints { make in
            make.top.equalTo(innerCoinInfoView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }
        
        coinInfoContainerView.addSubview(coinImageView)
        coinImageView.snp.makeConstraints { make in
            make.top.equalTo(coinBorderView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(34)
        }
        
        coinInfoContainerView.addSubview(currentTotalCoinLabel)
        currentTotalCoinLabel.snp.makeConstraints { make in
            make.top.equalTo(coinBorderView.snp.bottom).offset(10)
            make.leading.equalTo(coinImageView.snp.trailing).offset(8)
            make.height.equalTo(34)
        }
        
        coinInfoContainerView.addSubview(coinChargeButton)
        coinChargeButton.snp.makeConstraints { make in
            make.height.equalTo(34)
            make.top.equalTo(coinBorderView.snp.bottom).offset(10)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        
        coinInfoContainerView.addSubview(currentCoinDescriptionLabel)
        currentCoinDescriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(coinImageView.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        let paymentCoinString = "마이_내코인_결제코인".localized
        let bonusCoinString = "마이_내코인_보너스코인".localized
        
        currentCoinDescriptionLabel.text = "\(paymentCoinString) 0 ・ \(bonusCoinString) 0"
        currentCoinDescriptionLabel.highlightNumbers(with: UIColor(.brandRed))
        
        coinChargeButton.addTarget(self, action: #selector(coinChargeButtonTapped), for: .touchUpInside)
        
        
        myCoinLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(myCoinLabelTapped))
        myCoinLabel.addGestureRecognizer(tap)
    }
    
    
    @objc func myCoinLabelTapped() {
        let currentTotalCoinLabelText: String = currentTotalCoinLabel.text ?? "0"
        guard let vc = AppContext.container.resolve(MyCoinViewController.self,
                                                    arguments: currentTotalCoinLabelText, "0") else { return }
        navigationController?.pushHidesBottomBarViewController(vc)
    }
    
    @objc func coinChargeButtonTapped(_ sender: Any) {
        let currentTotalCoinLabelText: String = currentTotalCoinLabel.text ?? "0"
        guard let vc = AppContext.container.resolve(InAppPurchaseViewController.self,
                                                    argument: currentTotalCoinLabelText ) else { return }
        vc.delegate = self
        navigationController?.pushHidesBottomBarViewController(vc)
    }
    
    private func setupMembershipView() {
        
        contentView.addSubview(membershipContainerView)
        membershipContainerView.snp.makeConstraints { make in
            make.top.equalTo(coinInfoContainerView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(80)
        }
        
        membershipContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        let membershipStateView = LZSnackMembershipView(type: LZSnackMembershipState.allCases.randomElement()!)
        membershipContainerView.addSubview(membershipStateView)
        membershipStateView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
        membershipContainerView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(membershipContainerTapped))
        membershipContainerView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func membershipContainerTapped() {
        guard let vc = AppContext.container.resolve(MembershipViewController.self) else { return }
        navigationController?.pushHidesBottomBarViewController(vc)
        
//        vc.modalPresentationStyle = .overCurrentContext
//        self.present(vc, animated: true)
    }
    
    private func setupMenuStackView() {
        contentView.addSubview(menuStackView)
        menuStackView.snp.makeConstraints { make in
            make.top.equalTo(membershipContainerView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        let menuTitles = [
            "마이_결제내역_타이틀".localized,
            "마이_내문의_타이틀".localized,
            "마이_고객지원_타이틀".localized,
            "마이_이용약관_타이틀".localized,
            "마이_설정_타이틀".localized
        ]
        
        menuTitles.enumerated().forEach { index, title in
            let button = LZSnackLeftTextButton(type: .system)
            
            button.tag = index
            button.setTitle(title, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .pretendardMedium(size: 16)
//            button.enablePressAnimation().
            // 위/아래 16pt 패딩, 좌우 인셋도 살짝 줘서 텍스트·아이콘 여유 확보
            button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8)

            // 오른쪽 끝에 들어갈 화살표 아이콘
            let icon = UIImage(named: "ic_chevron_right_white")?.withRenderingMode(.alwaysOriginal)
            button.setImage(icon, for: .normal)
            button.tintColor = .foregroundSubtler

            // 텍스트-이미지 간 간격 없애고, layoutSubviews에서 직접 위치 제어
            button.imageEdgeInsets = .zero
            button.titleEdgeInsets = .zero
            
            button.addTarget(self, action: #selector(menuButtonTapped(_:)), for: .touchUpInside)

            menuStackView.addArrangedSubview(button)
        }
    }
    
    
    @objc private func menuButtonTapped(_ sender: UIButton) {
        guard let type = MenuType(rawValue: sender.tag) else { return }
        switch type {
        case .paymentHistory:
            guard let vc = AppContext.container.resolve(PaymentHistoryViewController.self) else { return }
            navigationController?.pushHidesBottomBarViewController(vc)
        case .myInquiries:
            break
        case .customerSupport:
            break
        case .termsOfService:
            guard let vc = AppContext.container.resolve(SignUpAgreementListViewController.self) else { return }
            navigationController?.pushHidesBottomBarViewController(vc)
        case .settings:
            guard let vc = AppContext.container.resolve(SettingViewController.self) else { return }
            navigationController?.pushHidesBottomBarViewController(vc)
        }
    }
    
    
    private func bind() {
        NotificationCenter.default.publisher(for: .LZSChangeAccountNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.setUserInfoText()
                self?.fetchData()
            }.store(in: &subscriptions)
        
        NotificationCenter.default.publisher(for: .LZSChangeLocaleStringNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.setLocalizedText()
            }.store(in: &subscriptions)
        
        viewModel.$isLogoutSuccess
            .receive(on: RunLoop.main)
            .sink { [weak self] isLogoutSuccess in
                guard let isLogoutSuccess = isLogoutSuccess else { return }
                if isLogoutSuccess {
                    let popup = LZSnackAlertPopupView(
                        width: 320,
                        height: 222,
                        title: "로그아웃 성공",
                        message: "\n로그인 타입 : \(Defaults.userLoginType)\n로그인 이메일 : \(Defaults.userEmail)",
                        buttonTitle: "닫기",
                        handler: { [weak self] in
                            self?.scrollView.setContentOffset(.zero, animated: true)
                        }
                    )
                    popup.show()
                }
            }.store(in: &subscriptions)
        
        viewModel.$userCoinEntity
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] userCoinEntity in
                self?.scrollView.refreshControl?.endRefreshing()
                let paymentCoinString = "마이_내코인_결제코인".localized
                let bonusCoinString = "마이_내코인_보너스코인".localized
                self?.currentTotalCoinLabel.text = "\(userCoinEntity.coin)"
                self?.currentCoinDescriptionLabel.text = "\(paymentCoinString) \(userCoinEntity.coin) ・ \(bonusCoinString) \(userCoinEntity.bonusCoin)"
                self?.currentCoinDescriptionLabel.highlightNumbers(with: UIColor(.brandRed))
            }.store(in: &subscriptions)
    }
    
    private func setUserInfoText() {
        if Defaults.userLoginType == SnsLoginType.guestMode.rawValue {
            userNameLabel.text = "마이_게스트_타이틀".localized
            userEmailLabel.text = Defaults.userEmail
            logoutButton.isHidden = true
            loginButton.isHidden = false
            userLoginTypeImageView.isHidden = true
            
            userEmailLabel.snp.updateConstraints { make in
                make.leading.equalTo(userLoginTypeImageView.snp.trailing).offset(-16)
            }
            
        } else {
            userNameLabel.text = Defaults.userName
            userEmailLabel.text = Defaults.userEmail
            logoutButton.isHidden = false
            loginButton.isHidden = true
            userLoginTypeImageView.isHidden = false
            
            switch Defaults.userLoginType {
            case SnsLoginType.apple.rawValue:
                userLoginTypeImageView.image = UIImage(named: "apple_logo_white")
            case SnsLoginType.google.rawValue:
                userLoginTypeImageView.image = UIImage(named: "google_logo")
            case SnsLoginType.facebook.rawValue:
                userLoginTypeImageView.image = UIImage(named: "facebook_logo")
            default:
                break
            }
            
            userEmailLabel.snp.updateConstraints { make in
                make.leading.equalTo(userLoginTypeImageView.snp.trailing).offset(4)
            }
        }
    }
    
    private func setLocalizedText() {
//        changeLanguageLabel.text = "changeLanguage".localized
//        faqLabel.text = "faq".localized
    }
    
}


extension MyPageViewController: InAppPurchaseDismissNotifying {
    
    func willDismiss(_ viewController: UIViewController) {
        printX("코인충전소 디스미스")
    }
    
    func didDismiss(_ viewController: UIViewController) {
        printX("코인충전소 디스미스")
        
        viewModel.fetchUserCoinBalance()
    }
        
}

extension MyPageViewController: TitleRootNavigationBarDelegate {
    
}
