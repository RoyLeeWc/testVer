//
//  WithdrawViewController.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/21/25.
//


import UIKit
import SnapKit
import SwiftyUserDefaults
import Combine

final class WithdrawViewController: UIViewController, ChildNavigationBarPresentable {
    // MARK: - UI Components
    let childNavigationBar = ChildNavigationBar()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private var subscriptions = Set<AnyCancellable>()
    
    private let viewModel: WithdrawViewModel
    
    private var reasons: [WithdrawalReasonEntity] = []
    private var selectedReasonId: Int?
    
    init?(viewModel: WithdrawViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 20)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private let thankYouLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 16)
        label.textColor = UIColor(.foregroundSubtler)
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let checkListTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 16)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private let checkListTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
        textView.textContainer.lineFragmentPadding = 0
        textView.backgroundColor = UIColor.backgroundRaisedDefault
        textView.roundCorners(cornerRadius: 4)
        return textView
    }()
    
    private lazy var noticeAllowCheckBox: LZSnackCheckBox = {
        let checkBox = LZSnackCheckBox()
        return checkBox
    }()
    
    private let noticeAllowTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 16)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private let noticeWithdrawReasonTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 16)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private let withdrawSelectBoxContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.roundCorners(cornerRadius: 4)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(.borderInput).cgColor
        return view
    }()
    
    private let withdrawPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 14)
        label.textColor = UIColor(.foregroundSubtler)
        label.textAlignment = .left
        return label
    }()
    
    private let selectBoxIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_chevron_down")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let withdrawInputTextView: UITextView = {
        let view = UITextView()
        view.backgroundColor = .clear
        view.roundCorners(cornerRadius: 4)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(.borderInput).cgColor
        
        view.textContainerInset = UIEdgeInsets(top: 12.0, left: 10.0, bottom: 12.0, right: 12.0)
        
        view.font = .pretendardRegular(size: 14)
        view.textColor = UIColor(.foregroundSubtler)
        
        return view
    }()
    
    private let withdrawReasonDropDown = LZSnackDropDown()
    
    private var floatingActionButtonBottomConstraint: Constraint!
    private let floatingActionButton: UIButton = {
        let floatingActionButton = UIButton(type: .system)
        floatingActionButton.setTitle("서비스 탈퇴", for: .normal)
        floatingActionButton.titleLabel?.font = .pretendardSemiBold(size: 16)
        floatingActionButton.backgroundColor = UIColor(.fillDisabled)
        floatingActionButton.tintColor = UIColor(.foregroundDisabled)
        floatingActionButton.layer.cornerRadius = 6
        
        return floatingActionButton
    }()
    
    
    private var isCheckBoxSelected: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        fetchData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        // 키보드 프레임과 애니메이션 지속 시간을 풀네임으로 바인딩
        guard let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let keyboardAnimationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        
        // Safe Area inset을 뺀 실제 키보드 높이 계산
        let safeAreaBottomInset = view.safeAreaInsets.bottom
        let keyboardHeight = keyboardFrameValue.height - safeAreaBottomInset
        
        // 제약(offset) 업데이트
        floatingActionButtonBottomConstraint.update(offset: -keyboardHeight - 20)
        
        // 키보드 애니메이션과 동기화
        UIView.animate(withDuration: keyboardAnimationDuration) {
            self.view.layoutIfNeeded()
            
            self.scrollView.scrollToBottom(animated: false)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        // 키보드 숨김 애니메이션 지속 시간
        guard let keyboardAnimationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        
        // 원래 위치로 복원
        floatingActionButtonBottomConstraint.update(offset: -20)
        
        UIView.animate(withDuration: keyboardAnimationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        withdrawReasonDropDown.dismiss()
    }
    
    
    private func bind() {
        noticeAllowCheckBox.$checkboxState
            .receive(on: RunLoop.main)
            .sink { [weak self] checkboxState in
                guard let self = self else { return }
                self.isCheckBoxSelected = (checkboxState == .checked)
                self.updateFloatingActionButtonState()
            }
            .store(in: &subscriptions)
        
        withdrawReasonDropDown.$isShowDropDown
            .receive(on: RunLoop.main)
            .sink { [weak self] isShowDropDown in
                if isShowDropDown {
                    self?.selectBoxIconImageView.image = UIImage(named: "ic_chevron_up")
                } else {
                    self?.selectBoxIconImageView.image = UIImage(named: "ic_chevron_down")
                }
            }
            .store(in: &subscriptions)
        
        viewModel.$isLogoutSuccess
            .receive(on: RunLoop.main)
            .sink { [weak self] isLogoutSuccess in
                guard let self = self, let isLogoutSuccess = isLogoutSuccess else { return }
                if isLogoutSuccess {
                    guard let vc = AppContext.container.resolve(WithdrawResultViewController.self) else { return }
                    self.navigationController?.pushHidesBottomBarViewController(vc)
                }
            }
            .store(in: &subscriptions)
        
        // 탈퇴 사유 목록 바인딩
        viewModel.$reasons
            .receive(on: RunLoop.main)
            .sink { [weak self] list in
                guard let self = self else { return }
                self.reasons = list
                // 탈퇴사유 데이터소스 = title 배열
                self.withdrawReasonDropDown.dataSource = list.map { $0.title }
            }
            .store(in: &subscriptions)
        
        viewModel.$isWithdrawing
            .receive(on: RunLoop.main)
            .sink { [weak self] loading in
                // 로딩 인디케이터/버튼 비활성 등
                self?.floatingActionButton.isEnabled = !loading
            }
            .store(in: &subscriptions)
        
        viewModel.$withdrawSuccess
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] ok in
                guard let self, ok else { return }
                // 성공 화면 이동
                guard let vc = AppContext.container.resolve(WithdrawResultViewController.self) else { return }
                self.navigationController?.pushHidesBottomBarViewController(vc)
            }
            .store(in: &subscriptions)
        
        viewModel.$withdrawError
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] msg in
                guard let self else { return }
                LZSnackToastHelper.showOnce(on: self.view, toast: LZSnackToastView(text: msg), duration: 2.0)
            }
            .store(in: &subscriptions)
        
        viewModel.$subscriptionError
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] msg in
                guard let self else { return }
                LZSnackToastHelper.showOnce(on: self.view, toast: LZSnackToastView(text: msg), duration: 2.0)
            }
            .store(in: &subscriptions)
        
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .backgroundDefault
        setupChildNavigationBar()
        childNavigationBar.titleLabel.text = "서비스 탈퇴"
        childNavigationBar.delegate = self
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        // 3. 뷰 계층 구성
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 4. SnapKit 제약 설정
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(childNavigationBar.snp.bottom)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        // contentView는 scrollView의 contentLayoutGuide에 맞춘다
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)   // 스크롤 콘텐츠 전체
            make.width.equalTo(scrollView.frameLayoutGuide)     // 가로는 스크롤 뷰 너비와 같게
        }
        
        contentView.addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(28)
        }
        
        contentView.addSubview(thankYouLabel)
        thankYouLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(userNameLabel.snp.bottom).offset(8)
        }
        
        
        contentView.addSubview(checkListTitleLabel)
        checkListTitleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(thankYouLabel.snp.bottom).offset(24)
        }
        
        contentView.addSubview(checkListTextView)
        checkListTextView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(checkListTitleLabel.snp.bottom).offset(8)
        }
        
        contentView.addSubview(noticeAllowCheckBox)
        noticeAllowCheckBox.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(checkListTextView.snp.bottom).offset(8)
            make.size.equalTo(24)
        }
        
        contentView.addSubview(noticeAllowTitleLabel)
        noticeAllowTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(noticeAllowCheckBox)
            make.leading.equalTo(noticeAllowCheckBox.snp.trailing).offset(2)
            make.height.equalTo(49)
        }
        
        contentView.addSubview(noticeWithdrawReasonTitleLabel)
        noticeWithdrawReasonTitleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(noticeAllowTitleLabel.snp.bottom).offset(34)
            make.bottom.lessThanOrEqualToSuperview().offset(-20)
        }
        
        
        contentView.addSubview(withdrawSelectBoxContainer)
        withdrawSelectBoxContainer.snp.makeConstraints { make in
            make.top.equalTo(noticeWithdrawReasonTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }
        
        withdrawSelectBoxContainer.addSubview(withdrawPlaceholderLabel)
        withdrawPlaceholderLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        
        withdrawSelectBoxContainer.addSubview(selectBoxIconImageView)
        selectBoxIconImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.size.equalTo(18)
        }
        
        
        contentView.addSubview(withdrawInputTextView)
        withdrawInputTextView.snp.makeConstraints { make in
            make.top.equalTo(withdrawSelectBoxContainer.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(200)
        }
        
        withdrawInputTextView.delegate = self
        
        contentView.addSubview(floatingActionButton)
        floatingActionButton.snp.makeConstraints { make in
            make.top.equalTo(withdrawInputTextView.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(56)
            floatingActionButtonBottomConstraint = make.bottom
                .equalToSuperview()
                .offset(-20)
                .constraint
        }
        
        withdrawSelectBoxContainer.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapAnchor))
        withdrawSelectBoxContainer.addGestureRecognizer(tap)
        
        
        let dismissKeyboardTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        dismissKeyboardTapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissKeyboardTapGesture)
        
        configureDropDown()
        configureAllText()
        
        //scrollView.delaysContentTouches = false
        //scrollView.canCancelContentTouches = false   // 또는 false로 시험해보세요
        scrollView.isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true
        
        floatingActionButton.addTarget(self, action: #selector(withdrawButtonTapped), for: .touchUpInside)
    }
    private func fetchData() {
        viewModel.fetchWithdrawalReasons()
        viewModel.checkSubscription()
    }
    
    @objc func withdrawButtonTapped() {
        let isAbleWithdraw = floatingActionButton.backgroundColor != UIColor(.fillDisabled)
        guard isAbleWithdraw else { return }
        
        // 구독 여부 기반 분기
        let isActive = viewModel.hasActiveSubscription ?? false
        
        if isActive {
            // ✅ 구독 중 → 해지 안내 팝업
            onMain { [weak self] in
                guard let self else { return }
                let popup = LZSnackAlertPopupView(
                    width: 320, height: 222,
                    title: "구독 서비스를 해지하시겠어요?",
                    message: "정기 구독 서비스를 이용 중일 경우 구독 해지 후 탈퇴하실 수 있습니다.",
                    leftButtonTitle: "취소",
                    leftHandler: { },
                    rightButtonTitle: "해지하기",
                    rightHandler: { [weak self] in
                        // 원하는 해지 경로로 이동(앱스토어 구독설정, 멤버십 화면 등)
                        self?.openAppStoreSubscriptions()
                    }
                )
                popup.show()
            }
        } else {
            // ✅ 미구독 → 기존 탈퇴 흐름 그대로
            let reasonText = self.isSelectedOther() ? self.withdrawInputTextView.text : ""
            self.viewModel.requestWithdrawal(
                selectedReasonId: self.selectedReasonId,
                reasonText: reasonText
            )
        }
    }
    
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // 필요 시 앱스토어 구독설정 오픈
    private func openAppStoreSubscriptions() {
        guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    
    // MARK: - Configure DropDown
    private func configureDropDown() {
        withdrawReasonDropDown.anchorView = withdrawSelectBoxContainer
        // selectionAction에서 id를 매핑
        withdrawReasonDropDown.selectionAction = { [weak self] index, title in
            guard let self = self else { return }
            guard self.reasons.indices.contains(index) else { return }
            let item = self.reasons[index]
            
            self.selectedReasonId = item.withdrawalCategoryId
            self.withdrawPlaceholderLabel.text = item.title
            self.withdrawReasonDropDown.dismiss()
            
            self.updateFloatingActionButtonState()
        }
        
    }
    
    private func configureAllText() {
        
        userNameLabel.text = Defaults.userName + " 회원님"
        thankYouLabel.text = "그 동안 저희 서비스를 아껴주신 시간에 감사 드립니다. 불편하게 느꼈던 부분을 알려 주시면, 더 좋은 서비스로 거듭날 수 있는 소중한 자료로 사용하겠습니다."
        thankYouLabel.setLineHeight(26)
        checkListTitleLabel.text = "서비스 탈퇴 전 확인하실 사항"
        noticeAllowTitleLabel.text = "안내사항을 모두 확인하였습니다."
        noticeWithdrawReasonTitleLabel.text = "불편했던 점을 알려주세요."
        withdrawPlaceholderLabel.text = "선택하세요"
        withdrawInputTextView.text = "내용을 입력하세요 (10자 이상)"
        
        let items = [
            "서비스 탈퇴 시 LEZHIN SNACK 서비스를 더 이상 이용하실 수 없습니다.",
            "주간 또는 월간 정기 구독 중일 경우 먼저 정기 구독 서비스를 해지해 주세요.",
            "탈퇴 시점에 보유하고 계신 코인은 모두 소멸되며, 향후 재 가입하더라도 복원되지 않습니다.",
            "지금까지 시청하신 콘텐츠의 정보를 포함한 활동내역은 모두 삭제됩니다.",
            "단, 댓글 등의 커뮤니티 활동 및 결제/구매내역, 1:1 문의내역은 서비스 이용약관에 명시된 기간만큼 보관 후 삭제됩니다. (탈퇴 후 5년)",
            "탈퇴 일시 기준 5일 후 다시 서비스에 가입하실 수 있습니다."
        ]
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.headIndent         = 8
        paragraph.firstLineHeadIndent = 0
        paragraph.paragraphSpacing  = 8
        paragraph.lineSpacing       = 4
        
        let attributeString: [NSAttributedString.Key: Any] = [
            .font: UIFont.pretendardRegular(size: 13),
            .foregroundColor: UIColor.foregroundSubtler,
            .paragraphStyle: paragraph
        ]
        
        let full = NSMutableAttributedString()
        for (index, item) in items.enumerated() {
            let isLast = (index == items.count - 1)
            let bulletLine = isLast
            ? "• \(item)"            // 마지막에는 줄바꿈 없이
            : "• \(item)\n"          // 그 외에는 줄바꿈 포함
            full.append(NSAttributedString(string: bulletLine, attributes: attributeString))
        }
        
        checkListTextView.attributedText = full
    }
    
    private func configureFloatingActionButton(isEnable: Bool) {
        if isEnable {
            floatingActionButton.setTitle("서비스 탈퇴", for: .normal)
            floatingActionButton.backgroundColor = UIColor(.fillBrand)
            floatingActionButton.tintColor = UIColor(.white)
        } else {
            floatingActionButton.setTitle("서비스 탈퇴", for: .normal)
            floatingActionButton.backgroundColor = UIColor(.fillDisabled)
            floatingActionButton.tintColor = UIColor(.foregroundDisabled)
        }
    }
    
    // MARK: - Actions
    @objc private func didTapAnchor() {
        withdrawReasonDropDown.show()
    }
    
}

// MARK: - ChildNavigationBarDelegate
extension WithdrawViewController: ChildNavigationBarDelegate {
    func childNavigationBarDidTapBack(_ navigationBar: ChildNavigationBar) {
        navigationController?.popViewController(animated: true)
    }
}

extension WithdrawViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor(.foregroundSubtler) {
            textView.text = nil // 텍스트를 날려줌
            textView.textColor = UIColor.white
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "내용을 입력하세요 (10자 이상)"
            textView.textColor = UIColor(.foregroundSubtler)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // 플레이스홀더 텍스트 상태일 땐 false 처리
        guard textView.textColor != UIColor(.foregroundSubtler) else {
            configureFloatingActionButton(isEnable: false)
            return
        }
        updateFloatingActionButtonState()
    }
    // “기타” 선택 여부 판단
    private func isSelectedOther() -> Bool {
        guard let id = selectedReasonId,
              let item = reasons.first(where: { $0.withdrawalCategoryId == id }) else { return false }
        let t = item.title.trimmingCharacters(in: .whitespaces)
        return t == "기타" || t.lowercased() == "other"
    }
    
    private func updateFloatingActionButtonState() {
        // placeholder 여부 → selectedReasonId nil 여부로 대체
        guard let _ = selectedReasonId else {
            configureFloatingActionButton(isEnable: false)
            return
        }
        let isChecked = isCheckBoxSelected
        
        if isSelectedOther() {
            let hasValidInput = withdrawInputTextView.textColor != UIColor(.foregroundSubtler)
            && withdrawInputTextView.text.count > 10
            configureFloatingActionButton(isEnable: isChecked && hasValidInput)
        } else {
            configureFloatingActionButton(isEnable: isChecked)
        }
    }
    
    
}

extension WithdrawViewController: UIGestureRecognizerDelegate {}

