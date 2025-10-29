//
//  MembershipViewController.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/27/25.
//

import UIKit
import SnapKit
import StoreKit


final class MembershipViewController: UIViewController, ChildRightCloseNavigationBarPresentable {
    
    
    var childNavigationBar = ChildRightCloseNavigationBar()
    
    var currentState = LZSnackMembershipState.allCases.randomElement()!
    
    private let membershipStateContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(.backgroundRaisedHigh)
        view.roundCorners(cornerRadius: 8)
        return view
    }()
    
    private let membershipStateLabel: LZSnackPaddingLabel = {
        let label = LZSnackPaddingLabel()
        label.textInsets = .init(top: 2, left: 4, bottom: 2, right: 4)
        label.font = .pretendardMedium(size: 11)
        label.textColor = .white
        label.textAlignment = .center
        label.roundCorners(cornerRadius: 4)
        return label
    }()
    
    private let membershipStateDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardSemiBold(size: 16)
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.textColor = .white
        return label
    }()
    
    private let membershipStateIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    
    private let paymentInfoTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardSemiBold(size: 16)
        label.textColor = .white
        return label
    }()
    
    private let paymentInfoBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(.borderDefault)
        return view
    }()
    
    private let recentPaymentDateTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 13)
        label.textColor = UIColor(.foregroundSubtler)
        return label
    }()
    
    private let recentPaymentDateLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 14)
        label.textColor = .white
        return label
    }()
    
    private let nextPaymentDateTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 13)
        label.textColor = UIColor(.foregroundSubtler)
        return label
    }()
    
    private let nextPaymentDateLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 14)
        label.textColor = .white
        return label
    }()
    
    private let paymentTypeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 13)
        label.textColor = UIColor(.foregroundSubtler)
        return label
    }()
    
    private let paymentTypeLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 14)
        label.textColor = .white
        return label
    }()
    
    
    private let subscriptionCancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("구독 해지", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .pretendardSemiBold(size: 14)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(.borderDefault).cgColor
        
        return button
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        LZSnackConcurrencyManager.run {
            try await TransactionManager.shared.fetchCurrentSubscriptions()
        }
    }
    
    
    private func setupUI() {
        setupChildNavigationBar()
        childNavigationBar.titleLabel.text = "정기구독 정보"
        childNavigationBar.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        view.backgroundColor = UIColor(.backgroundDefault)
        
        
        setupMembershipStateView()
        setupPaymentInfoView()
        setupSubscribeButton()
    }
    
    
    private func setupMembershipStateView() {
        
        view.addSubview(membershipStateContainerView)
        membershipStateContainerView.snp.makeConstraints { make in
            make.top.equalTo(childNavigationBar.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(101)
        }
        
        membershipStateContainerView.addSubview(membershipStateLabel)
        membershipStateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
        }
        
        membershipStateContainerView.addSubview(membershipStateIconImageView)
        membershipStateIconImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(57)
        }
        
        membershipStateContainerView.addSubview(membershipStateDescriptionLabel)
        membershipStateDescriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(membershipStateIconImageView.snp.leading).offset(-20)
            make.top.equalTo(membershipStateLabel.snp.bottom).offset(6)
        }
        
        switch currentState {
        case .neverSubscribed:
            break
        case .monthlySubscriptionCancelled:
            membershipStateLabel.text = "구독 해지"
            membershipStateLabel.textColor = UIColor(.foregroundSubtler)
            membershipStateLabel.backgroundColor = UIColor(.fillDisabled)
            membershipStateIconImageView.image = UIImage(named: "monthlySubscribedBanner")
            membershipStateDescriptionLabel.setText("월간 멤버십 무제한 시청이 12일 뒤 만료 예정이에요.", highlight: "12일 뒤 만료", lineHeight: 22)
            
        case .monthlySubscriptionActive:
            membershipStateLabel.text = "구독 중"
            membershipStateLabel.textColor = .white
            membershipStateLabel.backgroundColor = UIColor(.fillBrand)
            membershipStateIconImageView.image = UIImage(named: "monthlySubscribedBanner")
            membershipStateDescriptionLabel.setText("월간 멤버십으로 모든 작품을 무제한 시청 중이에요!", highlight: "월간 멤버십", lineHeight: 22)
            
        case .annualSubscriptionCancelled:
            membershipStateLabel.text = "구독 해지"
            membershipStateLabel.textColor = UIColor(.foregroundSubtler)
            membershipStateLabel.backgroundColor = UIColor(.fillDisabled)
            membershipStateIconImageView.image = UIImage(named: "annualSubscribedBanner")
            membershipStateDescriptionLabel.setText("연간 멤버십 무제한 시청이 12일 뒤 만료 예정이에요.", highlight: "12일 뒤 만료", lineHeight: 22)
            
        case .annualSubscriptionActive:
            membershipStateLabel.text = "구독 중"
            membershipStateLabel.textColor = .white
            membershipStateLabel.backgroundColor = UIColor(.fillBrand)
            membershipStateIconImageView.image = UIImage(named: "annualSubscribedBanner")
            membershipStateDescriptionLabel.setText("연간 멤버십으로 모든 작품을 무제한 시청 중이에요!", highlight: "연간 멤버십", lineHeight: 22)
        }
    }
    
    private func setupPaymentInfoView() {
        
        view.addSubview(paymentInfoTitleLabel)
        paymentInfoTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(membershipStateContainerView.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
        }
        
        view.addSubview(paymentInfoBorderView)
        paymentInfoBorderView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(1)
            make.top.equalTo(paymentInfoTitleLabel.snp.bottom).offset(8)
        }
        
        view.addSubview(recentPaymentDateLabel)
        recentPaymentDateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(paymentInfoBorderView.snp.bottom).offset(16)
        }
        
        let recentDateIconView = makeIconView(iconNamed: "ic_calendar")
        view.addSubview(recentDateIconView)
        recentDateIconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.size.equalTo(14)
            make.centerY.equalTo(recentPaymentDateLabel)
        }
        
        view.addSubview(recentPaymentDateTitleLabel)
        recentPaymentDateTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(recentDateIconView.snp.trailing).offset(4)
            make.centerY.equalTo(recentPaymentDateLabel)
        }
        
        
        
        view.addSubview(nextPaymentDateLabel)
        nextPaymentDateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(recentPaymentDateLabel.snp.bottom).offset(8)
        }
        
        let nextDateIconView = makeIconView(iconNamed: "ic_calendar")
        view.addSubview(nextDateIconView)
        nextDateIconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.size.equalTo(14)
            make.centerY.equalTo(nextPaymentDateLabel)
        }
        
        view.addSubview(nextPaymentDateTitleLabel)
        nextPaymentDateTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(nextDateIconView.snp.trailing).offset(4)
            make.centerY.equalTo(nextPaymentDateLabel)
        }
        
        
        view.addSubview(paymentTypeLabel)
        paymentTypeLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(nextPaymentDateLabel.snp.bottom).offset(8)
        }
        
        let paymentIconView = makeIconView(iconNamed: "ic_card")
        view.addSubview(paymentIconView)
        paymentIconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.size.equalTo(14)
            make.centerY.equalTo(paymentTypeLabel)
        }
        
        view.addSubview(paymentTypeTitleLabel)
        paymentTypeTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(paymentIconView.snp.trailing).offset(4)
            make.centerY.equalTo(paymentTypeLabel)
        }
        
        paymentInfoTitleLabel.text = "결제 정보"
        
        recentPaymentDateLabel.text = "2025.02.15"
        recentPaymentDateTitleLabel.text = "최근 결제일"
        
        nextPaymentDateLabel.text = "2025.02.15"
        nextPaymentDateTitleLabel.text = "다음 결제일"
        
        paymentTypeLabel.text = "애플 앱스토어 인앱결제"
        paymentTypeTitleLabel.text = "결제 수단"
    }
    
    
    private func makeIconView(iconNamed: String) -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: iconNamed))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }
    
    
    private func setupSubscribeButton() {
        view.addSubview(subscriptionCancelButton)
        subscriptionCancelButton.snp.makeConstraints { make in
            make.width.equalTo(88)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-40)
        }
        
        subscriptionCancelButton.addTarget(self, action: #selector(handleSubscribeButtonTapped), for: .touchUpInside)
    }
    
    @objc private func handleSubscribeButtonTapped() {
        LZSnackConcurrencyManager.run {
            if let windowScene = await self.view.window?.windowScene {
                try await AppStore.showManageSubscriptions(in: windowScene)
            }
        }
    }
    
}


extension MembershipViewController: ChildRightCloseNavigationBarDelegate {
    
    func childNavigationBarDidTapClose(_ navigationBar: ChildRightCloseNavigationBar) {
        guard let navigationController = navigationController else {
            self.dismiss(animated: true)
            return
        }
        
        navigationController.popViewController(animated: true)
    }
}


extension MembershipViewController: UIGestureRecognizerDelegate {
    
}
