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
    // 구독배너 뷰
    private var membershipStateView: LZSnackMembershipView?
    
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
    
    let nicknameEditButton: LZSnackEditButton = {
        let editButton = LZSnackEditButton()
        let customStyle = LZSnackEditButton.Style(
            font: .pretendardMedium(size: 16),
            textColor: .white
        )
        editButton.applyStyle(customStyle)
        editButton.contentHorizontalAlignment = .right
        return editButton
    }()
    private var isEditingNickname = false
    private let maxNicknameLen = 10
    private var lastValidNickname = ""
    private var expiringCoin = 0
    
    private let nicknameTextField: LZSnackSearchTextField = {
        let textField = LZSnackSearchTextField()
        textField.configureForNickname()
        textField.isHidden = true
        textField.alpha = 0
        textField.layer.cornerRadius = 8
        
        return textField
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // push/pop/모달 전부 포함해서 항상 키보드/편집 종료
        if isEditingNickname { finishNicknameEditing(save: false, animated: false) }
        else { view.endEditing(true) }
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
        
        scrollView.keyboardDismissMode = .onDrag     // 드래그로 키보드 내려감
        scrollView.delegate = self
    }
    
    private func fetchData() {
        viewModel.fetchUserCoinBalance()
        viewModel.fetchUserInfo()
        viewModel.checkSubscription()
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
        
        userTypeContainerView.addSubview(nicknameEditButton)
        nicknameEditButton.snp.makeConstraints { make in
            make.leading.equalTo(userNameLabel.snp.trailing).offset(8)
            make.centerY.equalTo(userNameLabel.snp.centerY)
            make.height.equalTo(16)
            make.width.equalTo(20)
        }
        nicknameEditButton.addTarget(self, action: #selector(nicknameEditButtonTapped), for: .touchUpInside)

        // 4) 닉네임 편집 텍스트필드 (처음엔 숨김)
        userTypeContainerView.addSubview(nicknameTextField)
        nicknameTextField.snp.makeConstraints { make in
            make.leading.equalTo(userNameLabel.snp.leading)
            make.centerY.equalTo(userNameLabel.snp.centerY)   // ← 라벨과 같은 Y (오버레이)
            make.trailing.equalToSuperview().inset(0)         // loginButton 참조 제거
            make.height.equalTo(34)
        }
        nicknameTextField.lzsSearchBarDelegate = self
        nicknameTextField.addTarget(self, action: #selector(onNicknameEditingChanged(_:)), for: .editingChanged)
        nicknameTextField.returnKeyType = .done
        nicknameTextField.isHidden = true
        nicknameTextField.alpha = 0
        nicknameTextField.delegate = self
        
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
    
    @objc func loginButtonOnTapped(_ sender: Any) {
        guard let vc = AppContext.container.resolve(UserAuthViewController.self) else { return }
        navigationController?.pushHidesBottomBarViewController(vc)
    }
    
    @objc func logoutButtonTapped(_ sender: Any) {
        onMain { [weak self] in
            let popup = LZSnackAlertPopupView(
                width: 320,
                height: 222,
                title: "로그아웃 하시겠어요?",
                message: "콘텐츠, 결제/코인 정보 등 회원님의 정보는\n안전하게 보관됩니다.",
                leftButtonTitle: "로그인 유지",
                leftHandler: { },
                rightButtonTitle: "로그아웃",
                rightHandler: { [weak self] in
                    self?.viewModel.requestLogout()
                }
            )
            popup.show()
        }
        
        
    }

    @objc func myCoinLabelTapped() {
        let currentTotalCoinLabelText: String = currentTotalCoinLabel.text ?? "0"
        guard let vc = AppContext.container.resolve(MyCoinViewController.self,
                                                    arguments: currentTotalCoinLabelText,String(expiringCoin)) else { return }
        navigationController?.pushHidesBottomBarViewController(vc)
    }
    
    @objc func coinChargeButtonTapped(_ sender: Any) {
        let currentTotalCoinLabelText: String = currentTotalCoinLabel.text ?? "0"
        guard let vc = AppContext.container.resolve(InAppPurchaseViewController.self,
                                                    argument: currentTotalCoinLabelText ) else { return }
        vc.delegate = self
        navigationController?.pushHidesBottomBarViewController(vc)
    }
    
    @objc private func nicknameEditButtonTapped() {
        if Defaults.userLoginType == AuthProvider.IOS_GUEST.rawValue {
            LZSnackToastHelper.showOnce(on: view, toast: LZSnackToastView(text: "로그인 후 닉네임을 변경할 수 있어요"), duration: 2.0)
            return
        }
        startNicknameEditing()
    }
    
    private func startNicknameEditing() {
        guard !isEditingNickname else { return }
        isEditingNickname = true
        userNameLabel.isHidden = true
        nicknameEditButton.isHidden = true

        nicknameTextField.text = userNameLabel.text
        lastValidNickname = nicknameTextField.text ?? ""
        nicknameTextField.isHidden = false
        userTypeContainerView.bringSubviewToFront(nicknameTextField)
        nicknameTextField.sendActions(for: .editingChanged) // X 버튼 표시 갱신
        nicknameTextField.becomeFirstResponder()

        UIView.animate(withDuration: 0.2) { self.nicknameTextField.alpha = 1 }
    }
    
    private func setupMembershipView() {
        
        contentView.addSubview(membershipContainerView)
        membershipContainerView.snp.makeConstraints { make in
            make.top.equalTo(coinInfoContainerView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(80)
        }
        
        membershipContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        let membershipView = LZSnackMembershipView(type: .neverSubscribed)
        membershipContainerView.addSubview(membershipView)
        membershipView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        membershipStateView = membershipView
        
        membershipContainerView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(membershipContainerTapped))
        membershipContainerView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func finishNicknameEditing(save: Bool, animated: Bool = true) {
        guard isEditingNickname else { return }
        isEditingNickname = false
        
        let raw = nicknameTextField.text ?? ""
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if save {
            if trimmed.isEmpty {
                LZSnackToastHelper.showOnce(on: view, toast: LZSnackToastView(text: "닉네임을 입력해 주세요"), duration: 1.5)
            } else if hasDisallowed(trimmed) {
                LZSnackToastHelper.showOnce(on: view, toast: LZSnackToastView(text: "이모티콘/특수문자는 사용할 수 없어요"), duration: 1.5)
            } else if trimmed.count > maxNicknameLen {
                LZSnackToastHelper.showOnce(on: view, toast: LZSnackToastView(text: "닉네임은 최대 10자까지예요"), duration: 1.5)
            } else {
                viewModel.updateNickname(trimmed)
//                userNameLabel.text = trimmed   // API 붙일 땐 여기서 호출
            }
        }
        
        nicknameTextField.resignFirstResponder()
        
        let hideBlock = {
            self.nicknameTextField.alpha = 0
        }
        let completeBlock: (Bool) -> Void = { _ in
            self.nicknameTextField.isHidden = true
            self.userNameLabel.isHidden = false
            self.nicknameEditButton.isHidden = false
        }
        
        if animated {
            UIView.animate(withDuration: 0.18, animations: hideBlock, completion: completeBlock)
        } else {
            hideBlock()
            completeBlock(true)
        }
    }

    
    @objc private func onNicknameEditingChanged(_ tf: UITextField) {
        // 한글 조합 중엔 제한 X (최종 커밋에 검사)
        guard tf.markedTextRange == nil else { return }
        let text = tf.text ?? ""
        if hasDisallowed(text) || trimmedLen(text) > maxNicknameLen {
            tf.text = lastValidNickname   // 불가 → 롤백
        } else {
            lastValidNickname = text      // 통과 → 최신 유효값 기억
        }
    }
    
    @objc private func keyboardWillHide() {
        // 키보드 내려갈 때 편집 중이면 취소(저장 X)
        if isEditingNickname { finishNicknameEditing(save: false) }
    }
    
    @objc private func membershipContainerTapped() {
        let info = viewModel.subscriptionInfo
        let state = viewModel.membershipState
        
        ///------------구독자 서비스 적용전까지 만---------
        if let vc = AppContext.container.resolve(MembershipViewController.self) {
            vc.configure(subscriptionInfo: info, state: .monthlySubscriptionActive)
            navigationController?.pushHidesBottomBarViewController(vc)
        }
        
//        if state == .neverSubscribed {
//            
//        } else {
//   
//            if let vc = AppContext.container.resolve(MembershipViewController.self) {
//                vc.configure(subscriptionInfo: info, state: .annualSubscriptionActive)
//                navigationController?.pushHidesBottomBarViewController(vc)
//            }
//        }
        
        
//        guard let vc = AppContext.container.resolve(MembershipViewController.self) else { return }
//        navigationController?.pushHidesBottomBarViewController(vc)
//        
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
        if isEditingNickname { finishNicknameEditing(save: false, animated: false) }
        else { view.endEditing(true) } // 혹시 모를 firstResponder 정리
        
        guard let type = MenuType(rawValue: sender.tag) else { return }
        switch type {
        case .paymentHistory:
            if Defaults.userLoginType == SnsLoginType.guestMode.rawValue {
                onMain { [weak self] in
                    let popup = LZSnackAlertPopupView(
                        width: 320,
                        height: 222,
                        title: "로그인 안내",
                        message: "게스트 모드에서는 불가능한 메뉴 입니다.",
                        leftButtonTitle: "닫기",
                        leftHandler: { },
                        rightButtonTitle: "로그인 하기",
                        rightHandler: { [weak self] in
                            guard let vc = AppContext.container.resolve(UserAuthViewController.self) else { return }
                            self?.navigationController?.pushHidesBottomBarViewController(vc)
                        }
                    )
                    popup.show()
                }
            } else {
                guard let vc = AppContext.container.resolve(PaymentHistoryViewController.self) else { return }
                navigationController?.pushHidesBottomBarViewController(vc)
            }
            
        case .myInquiries:
            break
        case .customerSupport:
            guard let vc = AppContext.container.resolve(CustomerSupportViewController.self) else { return }
                navigationController?.pushHidesBottomBarViewController(vc)
        case .termsOfService:
            guard let vc = AppContext.container.resolve(TermsListViewController.self) else { return }
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
        
        viewModel.$membershipState
            .combineLatest(viewModel.$subscriptionInfo)
            .receive(on: RunLoop.main)
            .sink { [weak self] state, info in
                guard let self else { return }
                if self.membershipStateView == nil { self.setupMembershipView() }
                self.membershipStateView?.configure(state: state, info: info)
            }
            .store(in: &subscriptions)
        
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
                let totalCoin = userCoinEntity.coin + userCoinEntity.bonusCoin
                self?.currentTotalCoinLabel.text = "\(totalCoin)"
                self?.expiringCoin = Int(userCoinEntity.expiringCoin)
                self?.currentCoinDescriptionLabel.text = "\(paymentCoinString) \(userCoinEntity.coin) ・ \(bonusCoinString) \(userCoinEntity.bonusCoin)"
                self?.currentCoinDescriptionLabel.highlightNumbers(with: UIColor(.brandRed))
            }.store(in: &subscriptions)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        viewModel.$updatedNickname
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] nick in
                guard let self = self else { return }
                self.userNameLabel.text = nick
                
                // 편집 UI 정리
                self.nicknameTextField.resignFirstResponder()
                self.nicknameTextField.isHidden = true
                self.nicknameTextField.alpha = 0
                self.userNameLabel.isHidden = false
                self.nicknameEditButton.isHidden = false
                self.isEditingNickname = false
                
            }
            .store(in: &subscriptions)
        
        // 실패: 토스트 표시 (UI는 그대로 유지해서 사용자가 수정 후 재시도 가능)
        viewModel.$updateNicknameError
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] msg in
                guard let self = self else { return }
                let toast = LZSnackToastView(text: msg)
                LZSnackToastHelper.showOnce(on: self.view, toast: toast, duration: 1.8)
            }
            .store(in: &subscriptions)
        
        viewModel.$userInfo
            .compactMap { $0 }                 //
            .receive(on: RunLoop.main)
            .sink { [weak self] (info: UserInfoEntity) in
                guard let self = self else { return }
                if LZSUtil.isNotGuestMode() {
                    self.userNameLabel.text = info.nickname
                    self.userEmailLabel.text = info.email ?? "이메일 없음"
                } else {
                    self.userEmailLabel.text = info.nickname ?? ""
                }
                
                switch info.joinType {
                case .apple:
                    self.logoutButton.isHidden = false
                    self.loginButton.isHidden = true
                    self.userLoginTypeImageView.isHidden = false
                    self.userLoginTypeImageView.image = UIImage(named: "apple_logo_white")
                case .google:
                    self.logoutButton.isHidden = false
                    self.loginButton.isHidden = true
                    self.userLoginTypeImageView.isHidden = false
                    self.userLoginTypeImageView.image = UIImage(named: "google_logo")
                case .facebook:
                    self.logoutButton.isHidden = false
                    self.loginButton.isHidden = true
                    self.userLoginTypeImageView.isHidden = false
                    self.userLoginTypeImageView.image = UIImage(named: "facebook_logo")
                case .lezhin:
                    self.logoutButton.isHidden = false
                    self.loginButton.isHidden = true
                    self.userLoginTypeImageView.isHidden = false
                    self.userLoginTypeImageView.image = UIImage(named: "lezhin_logo")
                    
                default:
                    break
                }
            }
            .store(in: &subscriptions)
        
        
    }
    
    private func setUserInfoText() {
        if Defaults.userLoginType == AuthProvider.IOS_GUEST.rawValue {
            userNameLabel.text = "마이_게스트_타이틀".localized
            userEmailLabel.text = Defaults.userEmail
            logoutButton.isHidden = true
            loginButton.isHidden = false
            userLoginTypeImageView.isHidden = true
            nicknameEditButton.isHidden = true
            userEmailLabel.snp.updateConstraints { make in
                make.leading.equalTo(userLoginTypeImageView.snp.trailing).offset(-16)
            }
            
        } else {
            userNameLabel.text = Defaults.userName
            userEmailLabel.text = Defaults.userEmail
            logoutButton.isHidden = false
            loginButton.isHidden = true
            userLoginTypeImageView.isHidden = false
            nicknameEditButton.isHidden = false
            
            switch Defaults.userLoginType {
            case AuthProvider.APPLE.rawValue:
                userLoginTypeImageView.image = UIImage(named: "apple_logo_white")
            case AuthProvider.GOOGLE.rawValue:
                userLoginTypeImageView.image = UIImage(named: "google_logo")
            case AuthProvider.FACEBOOK.rawValue:
                userLoginTypeImageView.image = UIImage(named: "facebook_logo")
            case AuthProvider.LEZHIN.rawValue:
                userLoginTypeImageView.image = UIImage(named: "lezhin_logo")
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
    private func trimmedLen(_ s: String) -> Int {
        s.trimmingCharacters(in: .whitespacesAndNewlines).count
    }

    // 한글/영문/숫자/공백만 허용 (이모지·특수문자 불가)
    private func hasDisallowed(_ s: String) -> Bool {
        for sc in s.unicodeScalars {
            if sc.properties.isEmoji || sc.properties.isEmojiPresentation { return true } // 이모지 불가
            let v = sc.value
            let isSpace     = (v == 0x20)                             // space
            let isDigit     = (0x30...0x39).contains(v)
            let isLatin     = (0x41...0x5A).contains(v) || (0x61...0x7A).contains(v)
            let isHangulSyl = (0xAC00...0xD7A3).contains(v)           // 한글 음절
            let isHangulJamo = (0x1100...0x11FF).contains(v) || (0x3130...0x318F).contains(v) // 자모/호환
            if !(isSpace || isDigit || isLatin || isHangulSyl || isHangulJamo) { return true }
        }
        return false
    }
    
}

extension MyPageViewController: UITextFieldDelegate, LZSnackSearchTextFieldDelegate {
    func searchTextFieldDidClear(_ textField: LZSnackSearchTextField) {
        
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField === nicknameTextField else { return true }
        if textField.markedTextRange != nil { return true } // 조합 중
        let current = textField.text ?? ""
        guard let r = Range(range, in: current) else { return true }
        let next = current.replacingCharacters(in: r, with: string)
        
        if hasDisallowed(next) { return false }
        if trimmedLen(next) > maxNicknameLen { return false } // 10자(양끝 공백 제외) 초과 차단
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField === nicknameTextField else { return true }
        finishNicknameEditing(save: true)   // ✅ 완료(확인/엔터)로 저장
        return false
    }
    
}

extension MyPageViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if isEditingNickname { finishNicknameEditing(save: false) }
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
