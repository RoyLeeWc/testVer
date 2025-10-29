//
//  LZSnackMembershipView.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/19/25.
//

import UIKit
import SnapKit


enum LZSnackMembershipState: CaseIterable {
    /// 구독 한 적이 없는 유저
    case neverSubscribed
    /// 월간 구독을 했으나 해지한 유저
    case monthlySubscriptionCancelled
    /// 월간 구독을 유지중인 유저
    case monthlySubscriptionActive
    /// 연간 구독을 했으나 해지한 유저
    case annualSubscriptionCancelled
    /// 연간 구독을 유지중인 유저
    case annualSubscriptionActive
    
    static var allCases: [LZSnackMembershipState] {
        return [
            .neverSubscribed,
            .annualSubscriptionActive, .annualSubscriptionCancelled,
            .monthlySubscriptionActive, .monthlySubscriptionCancelled
        ]
    }
}



final class LZSnackMembershipView: UIView {
    
    
    private let bannerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardSemiBold(size: 18)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 12)
        label.textColor = UIColor(.foregroundSubtler)
        label.textAlignment = .left
        return label
    }()
    
    private let stateLabel: UILabel = {
        let label = LZSnackPaddingLabel()
        label.textInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        label.font = .pretendardMedium(size: 11)
        label.textColor = .white
        label.backgroundColor = UIColor(.fillBrand)
        label.textAlignment = .center
        label.roundCorners(cornerRadius: 4)
        return label
    }()
    
    
    private let gradientLayer = CAGradientLayer()
    
    init(type: LZSnackMembershipState) {
        super.init(frame: .zero)
        
        setupUI(type)
        
    }
    
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("스토리보드/IB 지원하지 않음")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 뷰의 크기가 변경될 때마다 gradientLayer의 프레임을 업데이트
        gradientLayer.frame = bounds
    }
    
    func configure(state: LZSnackMembershipState, info: MySubscriptionInfoEntity?) {
        // 공통 초기화
        stateLabel.isHidden = false
        stateLabel.backgroundColor = UIColor(.fillBrand)
        stateLabel.textColor = .white
        descriptionLabel.font = .pretendardRegular(size: 12)
        descriptionLabel.textColor = UIColor(.foregroundSubtler)
        
        switch state {
        case .neverSubscribed:
            setupGradient()
            bannerImageView.image = UIImage(named: "neverSubscribedBanner")
            titleLabel.text = "월 3,900원으로"
            descriptionLabel.text = "모든 콘텐츠 마음껏 감상하기"
            descriptionLabel.font = .pretendardRegular(size: 14)
            descriptionLabel.textColor = .white
            stateLabel.isHidden = true
            
        case .monthlySubscriptionActive:
            bannerImageView.image = UIImage(named: "monthlySubscribedBanner")
            titleLabel.text = "멤버십_월간".localized
            stateLabel.text = "멤버십_구독중".localized
            descriptionLabel.text = nextPaymentText(info?.nextPaymentAt)
            
        case .monthlySubscriptionCancelled:
            bannerImageView.image = UIImage(named: "monthlySubscribedBanner")
            titleLabel.text = "멤버십_월간".localized
            stateLabel.text = "멤버십_구독해지".localized
            stateLabel.backgroundColor = UIColor(.fillDisabled)
            stateLabel.textColor = UIColor(.foregroundSubtler)
            descriptionLabel.text = endDateText(info?.endedAt)
            
        case .annualSubscriptionActive:
            bannerImageView.image = UIImage(named: "annualSubscribedBanner")
            titleLabel.text = "멤버십_연간".localized
            stateLabel.text = "멤버십_구독중".localized
            descriptionLabel.text = nextPaymentText(info?.nextPaymentAt)
            
        case .annualSubscriptionCancelled:
            bannerImageView.image = UIImage(named: "annualSubscribedBanner")
            titleLabel.text = "멤버십_연간".localized
            stateLabel.text = "멤버십_구독해지".localized
            stateLabel.backgroundColor = UIColor(.fillDisabled)
            stateLabel.textColor = UIColor(.foregroundSubtler)
            descriptionLabel.text = endDateText(info?.endedAt)
        }
        
        titleLabel.sizeToFit()
        stateLabel.sizeToFit()
    }

    private func endDateText(_ ms: Int64?) -> String {
        let base = "멤버십_만료일".localized
        guard let ms else { return "\(base): -" }
        return "\(base): \(format(ms))"
    }
    
    private func nextPaymentText(_ ms: Int64?) -> String {
        let base = "멤버십_다음_결제일".localized
        guard let ms else { return "\(base): -" }
        return "\(base): \(format(ms))"
    }
    
    private func format(_ ms: Int64) -> String {
        let date = Date(timeIntervalSince1970: Double(ms) / 1000.0)
        let f = DateFormatter()
        f.locale = .current
        f.timeZone = .current
        f.dateFormat = "yyyy.MM.dd"
        return f.string(from: date)
    }
    
    private func setupUI(_ type: LZSnackMembershipState) {
        
        addSubview(bannerImageView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(stateLabel)
        
        self.roundCorners(cornerRadius: 8)
        
        backgroundColor = UIColor(.backgroundRaisedHigh)
        
        bannerImageView.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview().inset(12)
            make.width.equalTo(72)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(19)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(24)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(16)
        }
        
        stateLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
            make.top.equalTo(titleLabel.snp.top)
            make.bottom.equalTo(titleLabel.snp.bottom)
        }
        
        switch type {
        case .neverSubscribed:
            setupGradient()
            bannerImageView.snp.remakeConstraints { make in
                make.trailing.top.bottom.equalToSuperview()
                make.width.equalTo(150)
            }
            bannerImageView.image = UIImage(named: "neverSubscribedBanner")
            
            titleLabel.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(16)
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalTo(bannerImageView.snp.leading)
                make.height.equalTo(24)
            }
            
            titleLabel.text = "월 3,900원으로"
            
            descriptionLabel.snp.remakeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(2)
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalTo(bannerImageView.snp.leading)
            }
            
            descriptionLabel.text = "모든 콘텐츠 마음껏 감상하기"
            descriptionLabel.font = .pretendardRegular(size: 14)
            descriptionLabel.textColor = .white
            
            stateLabel.isHidden = true
            
        case .monthlySubscriptionCancelled:
            bannerImageView.image = UIImage(named: "monthlySubscribedBanner")
            stateLabel.text = "멤버십_구독해지".localized
            titleLabel.text = "멤버십_월간".localized
            descriptionLabel.text = "\("멤버십_만료일".localized): 2025.04.26"
            titleLabel.sizeToFit()
            stateLabel.sizeToFit()
            stateLabel.backgroundColor = UIColor(.fillDisabled)
            stateLabel.textColor = UIColor(.foregroundSubtler)
        case .monthlySubscriptionActive:
            bannerImageView.image = UIImage(named: "monthlySubscribedBanner")
            stateLabel.text = "멤버십_구독중".localized
            titleLabel.text = "멤버십_월간".localized
            descriptionLabel.text = "\("멤버십_다음_결제일".localized): 2025.04.26"
            titleLabel.sizeToFit()
            stateLabel.sizeToFit()
        case .annualSubscriptionCancelled:
            bannerImageView.image = UIImage(named: "annualSubscribedBanner")
            stateLabel.text = "멤버십_구독해지".localized
            descriptionLabel.text = "\("멤버십_만료일".localized): 2025.04.26"
            titleLabel.text = "멤버십_연간".localized
            titleLabel.sizeToFit()
            stateLabel.sizeToFit()
            stateLabel.backgroundColor = UIColor(.fillDisabled)
            stateLabel.textColor = UIColor(.foregroundSubtler)
        case .annualSubscriptionActive:
            bannerImageView.image = UIImage(named: "annualSubscribedBanner")
            stateLabel.text = "멤버십_구독중".localized
            titleLabel.text = "멤버십_연간".localized
            descriptionLabel.text = "\("멤버십_다음_결제일".localized): 2025.04.26"
            titleLabel.sizeToFit()
            stateLabel.sizeToFit()
        }
        
        
    }
    
    private func setupGradient() {
        // 시작 색상: #E80023, 끝 색상: #2B2C2F
        let startColor = UIColor(.fillBrand).cgColor
        let midColor   = UIColor(.fillGradientRed).cgColor
        let endColor   = UIColor(.fillGradientRedEdge).cgColor

        gradientLayer.colors    = [startColor, midColor, endColor]
        gradientLayer.locations = [0.0, 0.3, 1.0]  // 30% 지점에서 중간 색상
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint   = CGPoint(x: 1.0, y: 0.5)

        layer.insertSublayer(gradientLayer, at: 0)
    }
    
}
