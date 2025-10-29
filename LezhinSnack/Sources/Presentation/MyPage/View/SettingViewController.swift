//
//  SettingViewController.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/20/25.
//


import UIKit
import SnapKit
import AVFoundation
import Combine
import SwiftyUserDefaults

final class SettingViewController: UIViewController, ChildNavigationBarPresentable {
    
    let childNavigationBar = ChildNavigationBar()
    
    private let viewModel: SettingViewModel
    
    private var subscriptions = Set<AnyCancellable>()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init?(viewModel: SettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let languageSettingContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let languageTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 16)
        label.textColor = .white
        label.textAlignment = .left
        label.text = "설정_언어_타이틀".localized
        return label
    }()
    
    private let languageSettingIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_chevron_right_white")
        return imageView
    }()
    
    private let marketingAlarmSettingContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let marketingAlarmTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 16)
        label.textColor = .white
        label.textAlignment = .left
        label.text = "설정_마케팅수신_타이틀".localized
        return label
    }()
    
    private let marketingAlarmSwitch: LZSnackSwitch = {
        let snackSwitch = LZSnackSwitch()
        return snackSwitch
    }()
    
    private let pushSettingContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let pushSettingTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 16)
        label.textColor = .white
        label.textAlignment = .left
        label.text = "설정_푸시_타이틀".localized
        return label
    }()
    
    private let pushSettingSwitch: LZSnackSwitch = {
        let snackSwitch = LZSnackSwitch()
        return snackSwitch
    }()
    
    private let withdrawContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let withdrawTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 16)
        label.textColor = .white
        label.textAlignment = .left
        label.text = "설정_서비스탈퇴_타이틀".localized
        return label
    }()
    
    private let withdrawSettingIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_chevron_right_white")
        return imageView
    }()
    
    private let deleteCacheContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    
    private let cacheTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 16)
        label.textColor = .white
        label.textAlignment = .left
        label.text = "설정_캐시삭제_타이틀".localized
        return label
    }()
    
    private let currentCacheLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 16)
        label.textColor = UIColor(.foregroundSubtler)
        label.textAlignment = .center
        label.text = "0mb"
        return label
    }()
    
    private let cacheIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_delete_gray")
        return imageView
    }()
    
    
    private let appVersionContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let appVersionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 16)
        label.textColor = .white
        label.textAlignment = .left
        label.text = "설정_앱버전_타이틀".localized
        return label
    }()
    
    private let appVersionDescLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 13)
        label.textColor = UIColor(.foregroundSubtler)
        label.textAlignment = .left
        label.text = "0"
        return label
    }()
    
    private let appUpdateLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 16)
        label.textColor = UIColor(.foregroundSubtler)
        label.textAlignment = .center
        label.text = "설정_앱버전_업데이트_타이틀".localized
        return label
    }()
    
    private var isInitialized = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
    }
    
    private func bind() {
        viewModel.$isPushGrant
            .compactMap { $0 }                                            // nil 건너뛰기
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.pushSettingSwitch.setOn($0, animated: false)
                
                if self.isInitialized {
                    let resultString = $0 ? "이제부터 푸시 알림을 받을 수 있어요" : "푸시 알림 설정이 해제되었어요"
                    let toastView = LZSnackToastView(text: resultString)
                    LZSnackToastHelper.showOnce(on: self.view, toast: toastView, duration: 2.0)
                }
                
                self.isInitialized = true
            }
            .store(in: &subscriptions)
        
        NotificationCenter.default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.getPushSetting()
            }
            .store(in: &subscriptions)
    }
    
    
    private func setupUI() {
        setupChildNavigationBar()
        childNavigationBar.titleLabel.text = "앱바_설정_타이틀".localized
        childNavigationBar.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        view.backgroundColor = UIColor(.backgroundDefault)
        
        setupLanguageSettingContainerView()
        setupMarketingAlarmSettingContainerView()
        setupPushSettingContainerView()
        setupWithdrawContainerView()
        setupDeleteCacheContainerView()
        setupAppVersionContainerView()
        
        viewModel.getPushSetting()
    }
    
    
    private func setupLanguageSettingContainerView() {
        view.addSubview(languageSettingContainerView)
        
        languageSettingContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(childNavigationBar.snp.bottom).offset(8)
            make.height.equalTo(58)
        }
        
        
        languageSettingContainerView.addSubview(languageTitleLabel)
        languageTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        languageSettingContainerView.addSubview(languageSettingIconImageView)
        languageSettingIconImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        
        languageSettingContainerView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tappedLanguageSettingContainerView))
        languageSettingContainerView.addGestureRecognizer(gesture)
        
    }
    
    @objc private func tappedLanguageSettingContainerView() {
        guard let vc = AppContext.container.resolve(ChangeLanguageViewController.self) else { return }
        navigationController?.pushHidesBottomBarViewController(vc)
    }
    
    
    private func setupMarketingAlarmSettingContainerView() {
        view.addSubview(marketingAlarmSettingContainerView)
        marketingAlarmSettingContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(languageSettingContainerView.snp.bottom)
            make.height.equalTo(58)
        }
        
        marketingAlarmSettingContainerView.addSubview(marketingAlarmTitleLabel)
        marketingAlarmTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        marketingAlarmSettingContainerView.addSubview(marketingAlarmSwitch)
        marketingAlarmSwitch.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        marketingAlarmSwitch.isToggleOnTapEnabled = false
        marketingAlarmSwitch.addTarget(
            self,
            action: #selector(didTappedMarketingAlarmSwitch(_:)),
            for: .touchUpInside
        )
        
    }
    
    @objc private func didTappedMarketingAlarmSwitch(_ sender: LZSnackSwitch) {
        if !sender.isOn {
            sender.setOn(true, animated: false)
            
            let toastView = LZSnackToastView(text: "이제부터 마케팅 수신정보를 받을 수 있어요")
            LZSnackToastHelper.showOnce(on: view, toast: toastView, duration: 2.0)
            
        } else {
            onMain { [weak self] in
                let popup = LZSnackAlertPopupView(
                    width: 320,
                    height: 222,
                    title: "마케팅 정보 수신 비활성화",
                    message: "회원님께 드리는 쿠폰, 할인 콘텐츠 등을 포함한 혜택 소식을 받을 수 없게 됩니다.",
                    leftButtonTitle: "알림 계속받기",
                    leftHandler: { },
                    rightButtonTitle: "알림 받지않기",
                    rightHandler: { [weak self] in
                        sender.setOn(false, animated: false)
                        
                        let toastView = LZSnackToastView(text: "마케팅 수신정보 설정이 해제되었어요")
                        LZSnackToastHelper.showOnce(on: self?.view, toast: toastView, duration: 2.0)
                    }
                )
                popup.show()
            }
        }
    }
    
    private func setupPushSettingContainerView() {
        view.addSubview(pushSettingContainerView)
        pushSettingContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(58)
            make.top.equalTo(marketingAlarmSettingContainerView.snp.bottom)
        }
        
        pushSettingContainerView.addSubview(pushSettingTitleLabel)
        pushSettingTitleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        pushSettingContainerView.addSubview(pushSettingSwitch)
        pushSettingSwitch.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        pushSettingSwitch.isToggleOnTapEnabled = false
        pushSettingSwitch.addTarget(
            self,
            action: #selector(didTappedPushSettingSwitch(_:)),
            for: .touchUpInside
        )
        
    }
    
    @objc private func didTappedPushSettingSwitch(_ sender: LZSnackSwitch) {
        if !sender.isOn {
            self.viewModel.moveToAppSetting()
        } else {
            onMain { [weak self] in
                let popup = LZSnackAlertPopupView(
                    width: 320,
                    height: 222,
                    title: "푸시 알림 비활성화",
                    message: "신규 콘텐츠 안내 및 혜택 이벤트, 쿠폰 지급 등의 소식을 받을 수 없게 됩니다.",
                    leftButtonTitle: "알림 계속받기",
                    leftHandler: { },
                    rightButtonTitle: "알림 받지않기",
                    rightHandler: { [weak self] in
                        self?.viewModel.moveToAppSetting()
                    }
                )
                popup.show()
            }
        }
    }
    
    private func setupWithdrawContainerView() {
        view.addSubview(withdrawContainerView)
        withdrawContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(58)
            make.top.equalTo(pushSettingContainerView.snp.bottom)
        }
        
        withdrawContainerView.addSubview(withdrawTitleLabel)
        withdrawTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        withdrawContainerView.addSubview(withdrawSettingIconImageView)
        withdrawSettingIconImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        withdrawContainerView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tappedWithdrawContainerView))
        withdrawContainerView.addGestureRecognizer(gesture)
        
    }
    
    @objc private func tappedWithdrawContainerView() {
        if Defaults.userLoginType == AuthProvider.IOS_GUEST.rawValue {
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
            guard let vc = AppContext.container.resolve(WithdrawViewController.self) else { return }
            navigationController?.pushHidesBottomBarViewController(vc)
        }
    }
    
    private func setupDeleteCacheContainerView() {
        
        // 메모리·디스크 사용량 출력
        print("Memory Cache:", URLCache.shared.currentMemoryUsage)  // 바이트 단위
        print("Disk Cache:  ", URLCache.shared.currentDiskUsage)    // 바이트 단위
        
        view.addSubview(deleteCacheContainerView)
        deleteCacheContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(58)
            make.top.equalTo(withdrawContainerView.snp.bottom)
        }
        
        deleteCacheContainerView.addSubview(cacheTitleLabel)
        cacheTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        deleteCacheContainerView.addSubview(cacheIconImageView)
        cacheIconImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        
        deleteCacheContainerView.addSubview(currentCacheLabel)
        currentCacheLabel.snp.makeConstraints { make in
            make.trailing.equalTo(cacheIconImageView.snp.leading)
            make.centerY.equalToSuperview()
        }
        
        
        let memoryBytes = URLCache.shared.currentMemoryUsage
        let diskBytes   = URLCache.shared.currentDiskUsage

        let memoryMB = Double(memoryBytes) / 1_048_576
        let diskMB   = Double(diskBytes)   / 1_048_576
        let totalMB  = memoryMB + diskMB

        // 소숫점 첫째 자리까지 포맷
        currentCacheLabel.text = String(format: "%.1f MB", totalMB)

        deleteCacheContainerView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tappedDeleteCacheContainerView))
        deleteCacheContainerView.addGestureRecognizer(gesture)
        
    }
    
    @objc private func tappedDeleteCacheContainerView() {
        onMain { [weak self] in
            let popup = LZSnackAlertPopupView(
                width: 320,
                height: 199,
                title: "캐시 삭제",
                message: "캐시를 삭제하시겠습니까?",
                leftButtonTitle: "삭제안함",
                leftHandler: { },
                rightButtonTitle: "삭제",
                rightHandler: { [weak self] in
                    guard let self = self else { return }
                    URLCache.shared.removeAllCachedResponses()
                    onMainAfter(delay: 1) { [weak self] in
                        let memoryBytes = URLCache.shared.currentMemoryUsage
                        let diskBytes   = URLCache.shared.currentDiskUsage

                        let memoryMB = Double(memoryBytes) / 1_048_576
                        let diskMB   = Double(diskBytes)   / 1_048_576
                        let totalMB  = memoryMB + diskMB
                        
                        self?.currentCacheLabel.text = String(format: "%.1f MB", totalMB)
                    }
                }
            )
            popup.show()
        }
    }
    
    private func setupAppVersionContainerView() {
        
        view.addSubview(appVersionContainerView)
        appVersionContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
            make.top.equalTo(deleteCacheContainerView.snp.bottom)
        }
        
        
        appVersionContainerView.addSubview(appVersionTitleLabel)
        appVersionTitleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
        }
        
        appVersionContainerView.addSubview(appVersionDescLabel)
        appVersionDescLabel.snp.makeConstraints { make in
            make.top.equalTo(appVersionTitleLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(16)
        }
        
        
        appVersionContainerView.addSubview(appUpdateLabel)
        appUpdateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(appVersionTitleLabel.snp.centerY)
        }
        
        
        appVersionDescLabel.text = "v\(LZSUtil.getAppVersion())"
        
    }
    
}





extension SettingViewController: ChildNavigationBarDelegate {
    func childNavigationBarDidTapBack(_ navigationBar: ChildNavigationBar) {
        navigationController?.popViewController(animated: true)
    }
}

extension SettingViewController: UIGestureRecognizerDelegate {
    
}
