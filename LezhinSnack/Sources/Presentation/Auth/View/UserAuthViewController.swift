//
//  Untitled.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/8/25.
//

import UIKit
import Toast
import Combine
import SwiftyUserDefaults
import SnapKit
import EasyTipView

final class UserAuthViewController: UIViewController, ChildRightCloseNavigationBarPresentable {
    
                
    var childNavigationBar = ChildRightCloseNavigationBar()
    
    let viewModel: UserAuthViewModel
    
    var subscriptions = Set<AnyCancellable>()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init?(viewModel: UserAuthViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 1. 로고 영역(컨테이너)
    private let logoContainer = UIView()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "login_logo"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "BalconyShortForm"
        label.font = .pretendardMedium(size: 16)
        label.textAlignment = .center
        return label
    }()
    
    // 2. SNS 로그인 버튼
    private var facebookLoginButton: UIButton = {
        let button = UIButton(type: .system)
        
        // 1) 타이틀·이미지 설정
        button.setTitle("Facebook으로 로그인", for: .normal)
        let rawIcon = UIImage(named: "facebook_logo")?.resized(to: CGSize(width: 20, height: 20))?.withRenderingMode(.alwaysOriginal)
        button.setImage(rawIcon, for: .normal)
        button.titleLabel?.font = .pretendardSemiBold(size: 16)
        
        // 2) 색상·모양
        button.backgroundColor = UIColor(.white)
        button.tintColor = UIColor(.foregroundInverse)
        button.layer.cornerRadius = 8
        
        // 3) 이미지와 타이틀 레이아웃
        button.contentHorizontalAlignment = .center
        // 이미지↔텍스트 간격: 12
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        
        return button
    }()
    
    private let facebookAnchor: UIView = {
        let anchor = UIView()
        anchor.backgroundColor = .clear
        return anchor
    }()
    
    private var googleLoginButton: UIButton = {
        let button = UIButton(type: .system)
        
        // 1) 타이틀·이미지 설정
        button.setTitle("google로 로그인", for: .normal)
        let rawIcon = UIImage(named: "google_logo")?.resized(to: CGSize(width: 20, height: 20))?.withRenderingMode(.alwaysOriginal)
        button.setImage(rawIcon, for: .normal)
        button.titleLabel?.font = .pretendardSemiBold(size: 16)
        
        // 2) 색상·모양
        button.backgroundColor = UIColor(.white)
        button.tintColor = UIColor(.foregroundInverse)
        button.layer.cornerRadius = 8
        
        // 3) 이미지와 타이틀 레이아웃
        button.contentHorizontalAlignment = .center
        // 이미지↔텍스트 간격: 12
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        
        return button
    }()
    
    private let googleAnchor: UIView = {
        let anchor = UIView()
        anchor.backgroundColor = .clear
        return anchor
    }()
    
    private var appleLoginButton: UIButton = {
        let button = UIButton(type: .system)
        
        // 1) 타이틀·이미지 설정
        button.setTitle("Apple로 로그인", for: .normal)
        let rawIcon = UIImage(named: "apple_logo")?.resized(to: CGSize(width: 20, height: 20))?.withRenderingMode(.alwaysOriginal)
        button.setImage(rawIcon, for: .normal)
        button.titleLabel?.font = .pretendardSemiBold(size: 16)
        
        // 2) 색상·모양
        button.backgroundColor = UIColor(.white)
        button.tintColor = UIColor(.foregroundInverse)
        button.layer.cornerRadius = 8
        
        // 3) 이미지와 타이틀 레이아웃
        button.contentHorizontalAlignment = .center
        // 이미지↔텍스트 간격: 12
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        
        return button
    }()
    
    private let appleAnchor: UIView = {
        let anchor = UIView()
        anchor.backgroundColor = .clear
        return anchor
    }()
    
    private let borderContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let borderTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(.foregroundSubtler)
        label.font = .pretendardRegular(size: 11)
        label.textAlignment = .center
        label.text = "또는"
        return label
    }()
    
    private let leftBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.25)
        return view
    }()
    
    private let rightBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.25)
        return view
    }()
    
    // 레진으로 로그인
    private var lezhinLoginButton: UIButton = {
        let button = UIButton(type: .system)
        
        // 1) 타이틀·이미지 설정
        button.setTitle("레진 계정으로 로그인", for: .normal)
        let rawIcon = UIImage(named: "lezhinIcon")?.resized(to: CGSize(width: 12, height: 12))?.withRenderingMode(.alwaysOriginal)
        button.setImage(rawIcon, for: .normal)
        button.titleLabel?.font = .pretendardSemiBold(size: 16)
        
        // 2) 색상·모양
        button.backgroundColor = UIColor(.lezhinBrandRed)
        button.tintColor = UIColor(.white)
        button.layer.cornerRadius = 8
        
        // 3) 이미지와 타이틀 레이아웃
        button.contentHorizontalAlignment = .center
        // 이미지↔텍스트 간격: 12
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        
        return button
    }()
    
    private let lezhinAnchor: UIView = {
        let anchor = UIView()
        anchor.backgroundColor = .clear
        return anchor
    }()
    
    private lazy var tooltipPreferences: EasyTipView.Preferences = {
        var preferences = EasyTipView.globalPreferences
        preferences.positioning.bubbleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        preferences.positioning.contentInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        preferences.drawing.font = .pretendardRegular(size: 13)
        return preferences
    }()

    private var spacingConstraint: Constraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setLastLoginTooltip()
    }
    
    
    private func bind() {

        viewModel.$needSignupFlow
            .compactMap { $0 }                      // (provider, email, token) 로 언랩
            .receive(on: RunLoop.main)
            .sink { [weak self] flow in
                guard let self = self else { return }
                // 이미 약관 화면이 떠있으면 중복 푸시 방지
                if self.navigationController?.topViewController is SignUpAgreementListViewController {
                    return
                }
                guard let vc = AppContext.container.resolve(SignUpAgreementListViewController.self) else { return }
                vc.showsChildNavBar = true   // push라면 네비바 있는 모드가 자연스러움
                
                // 약관 완료 콜백: 여기서 반드시 flow의 값 사용!
                vc.onAgreementsAccepted = { [weak self] _ in
                    guard let self = self else { return }
                    // 필요 시 마케팅/푸시 Defaults는 VC에서 세팅해두었다고 가정
                    self.viewModel.signupThenLogin(
                        provider: flow.provider,
                        email: flow.email,
                        token: flow.token,
                        agreeMarketing: Defaults.isAgreeMarketing,
                        agreePush: Defaults.isAgreePushNotification
                    )
                    self.viewModel.needSignupFlow = nil   // 한 번만 반응하게 초기화
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }.store(in: &subscriptions)
        
        viewModel.$isLoginSuccess
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoginSuccess in
                guard let isLoginSuccess = isLoginSuccess else { return }
                // 지금 네비게이션 스택의 최상단 VC가 '회원가입 완료' 화면인지 확인
                let isOnSignUpSuccess = (self?.navigationController?.topViewController is SignUpSuccessViewController)
                
                if isLoginSuccess {
                    if isOnSignUpSuccess {
                        // (필요하면 토큰/프로필 동기화 등 후처리만 조용히)
                        return
                    } else {
                        // 그 외 로그인 성공: 기존 동작 유지 (팝업 + 한 단계 뒤로)
                        let popup = LZSnackAlertPopupView(
                            width: 320,
                            height: 222,
                            title: "로그인 성공",
                            message: "\n로그인 타입 : \(Defaults.userLoginType)\n로그인 이메일 : \(Defaults.userEmail)",
                            buttonTitle: "닫기",
                            handler: { [weak self] in
                                self?.navigationController?.popViewController(animated: true)
                            }
                        )
                        popup.show()
                    }
                } else {
                    // 실패 처리
                    if isOnSignUpSuccess {
                        // 실패여도 성공 화면에 있다면 조용히 토스트만 (또는 유지)
                        self?.view.makeToast("로그인 실패", position: .center)
                    } else {
                        self?.view.makeToast("로그인 실패", position: .center)
                    }
                }
                
            }.store(in: &subscriptions)
    }
    
    private func setupUI() {
        
        view.backgroundColor = UIColor(.backgroundDefault)
        
        setupChildNavigationBar()
        childNavigationBar.titleLabel.text = ""
        childNavigationBar.delegate = self
        
        configureLezhinLoginView()
        configureSNSLoginView()
        
        // 1) 로고 컨테이너 추가 및 제약
        view.addSubview(logoContainer)
        logoContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            // 높이 = 화면 높이의 30%
            make.bottom.equalTo(facebookLoginButton.snp.top)
        }
        

        // 2) 로고 이미지뷰 중앙 배치 + 가변 크기
        logoContainer.addSubview(logoImageView)
        // 이미지 실제 비율 계산
        if let img = UIImage(named: "login_logo") {
//            let ratio = img.size.height / img.size.width
            let ratio = 80.0 / 185.0
            logoImageView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                // 너비 = 컨테이너 너비의 50%
                make.width.equalToSuperview().multipliedBy(0.5)
                // 높이 = 너비 × 비율
                make.height.equalTo(logoImageView.snp.width).multipliedBy(ratio)
            }
        }

        // 3) 타이틀 레이블 추가 및 간격 제약 (초기 offset=0)
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        
        titleLabel.text = "시작하는데 1분도 걸리지 않아요"
        titleLabel.textColor = .white
        
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.view.bringSubviewToFront(childNavigationBar)
    }
    
    func setLastLoginTooltip() {
        let anchor: UIView
        switch Defaults.lastLoginType {
        case AuthProvider.APPLE.rawValue:
            anchor = appleAnchor
        case AuthProvider.GOOGLE.rawValue:
            anchor = googleAnchor
        case AuthProvider.FACEBOOK.rawValue:
            anchor = facebookAnchor
        case AuthProvider.LEZHIN.rawValue:
            anchor = lezhinAnchor
        default:
            return
        }


        // 툴팁을 이 앵커 위에 달기
        EasyTipView.show(
            forView: anchor,
            withinSuperview: view,
            text: "마지막 로그인",
            preferences: tooltipPreferences,
            delegate: self
        )
    }
    
    private func configureLezhinLoginView() {
        view.addSubview(lezhinLoginButton)
        lezhinLoginButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(48)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
        lezhinLoginButton.addTarget(self, action: #selector(lezhinLoginButtonOnTapped), for: .touchUpInside)
        
        view.addSubview(borderContainerView)
        borderContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(15)
            make.bottom.equalTo(lezhinLoginButton.snp.top).offset(-12)
        }
        
        borderContainerView.addSubview(borderTitleLabel)
        borderTitleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        borderContainerView.addSubview(leftBorderView)
        leftBorderView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.height.equalTo(1)
            make.trailing.equalTo(borderTitleLabel.snp.leading).offset(-16)
        }
        
        borderContainerView.addSubview(rightBorderView)
        rightBorderView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(1)
            make.leading.equalTo(borderTitleLabel.snp.trailing).offset(16)
        }
        
        view.addSubview(lezhinAnchor)
        lezhinAnchor.snp.makeConstraints { make in
            // 버튼의 top, 버튼의 centerX 위치
            make.top.equalTo(lezhinLoginButton.snp.top).offset(12)
            make.centerX.equalTo(lezhinLoginButton.snp.centerX)
            make.width.height.equalTo(1.0)
        }
    }
    
    private func configureSNSLoginView() {
        view.addSubview(appleLoginButton)
        appleLoginButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(48)
            make.bottom.equalTo(borderContainerView.snp.top).offset(-12)
        }
        appleLoginButton.addTarget(self, action: #selector(appleLoginButtonOnTapped), for: .touchUpInside)
        
        
        view.addSubview(appleAnchor)
        appleAnchor.snp.makeConstraints { make in
            // 버튼의 top, 버튼의 centerX 위치
            make.top.equalTo(appleLoginButton.snp.top).offset(12)
            make.centerX.equalTo(appleLoginButton.snp.centerX)
            make.width.height.equalTo(1.0)
        }
        
        view.addSubview(googleLoginButton)
        googleLoginButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(48)
            make.bottom.equalTo(appleLoginButton.snp.top).offset(-12)
        }
        googleLoginButton.addTarget(self, action: #selector(googleLoginButtonOnTapped), for: .touchUpInside)
        
        
        view.addSubview(googleAnchor)
        googleAnchor.snp.makeConstraints { make in
            // 버튼의 top, 버튼의 centerX 위치
            make.top.equalTo(googleLoginButton.snp.top).offset(12)
            make.centerX.equalTo(googleLoginButton.snp.centerX)
            make.width.height.equalTo(1.0)
        }
        
        
        view.addSubview(facebookLoginButton)
        facebookLoginButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(48)
            make.bottom.equalTo(googleLoginButton.snp.top).offset(-12)
        }
        facebookLoginButton.addTarget(self, action: #selector(facebookLoginButtonOnTapped), for: .touchUpInside)
        
        view.addSubview(facebookAnchor)
        facebookAnchor.snp.makeConstraints { make in
            // 버튼의 top, 버튼의 centerX 위치
            make.top.equalTo(facebookLoginButton.snp.top).offset(12)
            make.centerX.equalTo(facebookLoginButton.snp.centerX)
            make.width.height.equalTo(1.0)
        }
        
        view.addSubview(facebookAnchor)
        facebookAnchor.snp.makeConstraints { make in
            // 버튼의 top, 버튼의 centerX 위치
            make.top.equalTo(facebookLoginButton.snp.top).offset(12)
            make.centerX.equalTo(facebookLoginButton.snp.centerX)
            make.width.height.equalTo(1.0)
        }
        
    }
    
    @objc func closeButtonOnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func lezhinLoginButtonOnTapped(_ sender: Any) {
        let vc = LezhinLoginWebViewController(environment: .dev)
        vc.onLoginSuccess = { accessToken in
            self.viewModel.requestLezhinLAuth(accessToken: accessToken)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func googleLoginButtonOnTapped(_ sender: Any) {
        viewModel.requestGoogleAuth()
    }
    
    @objc func appleLoginButtonOnTapped(_ sender: Any) {
        viewModel.requestAppleAuth()
    }
    
    @objc func facebookLoginButtonOnTapped(_ sender: Any) {
        viewModel.requestFacebookAuth()
    }
    
    @IBAction func logoutButtonOnTapped(_ sender: Any) {
        viewModel.requestLogout()
    }
    
}

extension UserAuthViewController: UIGestureRecognizerDelegate {
    
}

extension UserAuthViewController: ChildRightCloseNavigationBarDelegate {
    
    func childNavigationBarDidTapClose(_ navigationBar: ChildRightCloseNavigationBar) {
        guard let navigationController = navigationController else {
            self.dismiss(animated: true)
            return
        }
        
        navigationController.popViewController(animated: true)
    }
}

extension UserAuthViewController: UIPopoverPresentationControllerDelegate, EasyTipViewDelegate {
    func easyTipViewDidTap(_ tipView: EasyTipView) {
        
    }
    
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
    
    
}
