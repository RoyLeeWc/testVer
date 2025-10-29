//
//  OriginalCell.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/16/25.
//

import UIKit
import SnapKit

protocol OriginalCellDelegate: AnyObject {
    
    func tappedBottomButton(isAlreadyOpened: Bool, title: String )
    
}

final class OriginalCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    enum BottomContentState: Equatable {
        case play
        case alarm(date: Date)

        var icon: UIImage? {
            switch self {
            case .play:  return UIImage(named: "ic_play_fill_black")
            case .alarm:return UIImage(named: "ic_play_fill")
            }
        }

        var title: String {
            switch self {
            case .play:
                return "play".dynamicLocalized
            case .alarm(let date):
                let fmt = DateFormatter()
                fmt.dateFormat = "M월 d일 알람받기"
                return fmt.string(from: date)
            }
        }

        var foregroundColor: UIColor {
            switch self {
            case .play:  return .baseBlack
            case .alarm: return .white
            }
        }

        var backgroundColor: UIColor {
            switch self {
            case .play:  return .white
            case .alarm: return .snackBrandRed
            }
        }
    }
    
    private let mainImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let gradientLayer = CAGradientLayer()
    
    private let signatureContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let scriptLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardSemiBold(size: 16)
        label.textColor = UIColor(.whiteOpacity58)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private let titleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let signatureInnerView = UIView()
    
    private let signatureInfoLabel = {
        let label = UILabel()
        
        label.font = .pretendardSemiBold(size: 12)
        label.textColor = .white
        label.textAlignment = .left
        
        return label
    }()
    
    private let bottomButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.titleLabel?.font   = .pretendardSemiBold(size: 16)
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    
    private var iconView = UIView()
    
    weak var delegate: OriginalCellDelegate?
    
    var isAlreadyOpened = false
    
    private var bottomState: BottomContentState = .play
    
    private var title: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()  // 셀 내부 뷰들을 추가 및 제약조건 설정
        setupGestureRecognizers()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:)는 지원하지 않습니다. 코드 기반으로 구현해 주세요.")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    func reset() {
        // 이전 상태 정리
        mainImageView.image = nil
        title = ""
        titleImageView.image = nil
        scriptLabel.text = ""
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        // 뷰 크기에 맞춰 그라디언트 크기 업데이트
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = mainImageView.bounds
        CATransaction.commit()
    }
    
    private func setupUI() {
        
        isSkeletonable = true
        
        contentView.addSubview(mainImageView)
        mainImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        mainImageView.roundCorners(cornerRadius: 12)
        mainImageView.isUserInteractionEnabled = true
        
        contentView.addSubview(bottomButton)
        bottomButton.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.bottom.equalToSuperview().inset(20)
            make.leading.trailing.equalToSuperview().inset(28)
        }
        
        
        mainImageView.addSubview(signatureContainerView)
        signatureContainerView.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(bottomButton.snp.top).inset(-20)
        }
        
        mainImageView.addSubview(scriptLabel)
        scriptLabel.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(signatureContainerView.snp.top).inset(-18)
        }
        
        mainImageView.addSubview(titleImageView)
        titleImageView.snp.makeConstraints { make in
            make.height.equalTo(72)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(scriptLabel.snp.top).inset(-12)
        }
        
        signatureContainerView.addSubview(signatureInnerView)
        signatureInnerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        setupGradient()
    }

    func setBottomContainer(state: BottomContentState) {
        bottomState = state
        
        isAlreadyOpened = bottomState == .play ? true : false

        // 1) 아이콘을 24×24 로 리사이즈하고 템플릿 모드로 설정
        let icon = state.icon?
            .resized(to: CGSize(width: 24, height: 24))?
            .withRenderingMode(.alwaysTemplate)

        // 2) 버튼에 이미지·타이틀·색상 할당
        bottomButton.setImage(icon, for: .normal)
        bottomButton.tintColor      = state.foregroundColor    // 아이콘 색
        bottomButton.setTitle(state.title, for: .normal)
        bottomButton.setTitleColor(state.foregroundColor, for: .normal)
        bottomButton.backgroundColor = state.backgroundColor   // 배경색
    }
    
    
    func makeSignatureInfoView(titleText: String, tagType: TagType) {
        //기존에 추가된 뷰들 전부 제거
        signatureInnerView.subviews.forEach { $0.removeFromSuperview() }

        //레이블 텍스트 업데이트
        signatureInfoLabel.text = titleText

        //새로운 태그 뷰 생성
        iconView = LZSUtil.makeTagView(
            type: tagType,
            tagImageSize: CGSize(width: 14, height: 14)
        )
        iconView.roundCorners(cornerRadius: 2)

        //서브뷰로 추가
        signatureInnerView.addSubview(iconView)
        signatureInnerView.addSubview(signatureInfoLabel)

        //제약조건 재설정
        iconView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.height.equalTo(20)
        }
        signatureInfoLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(4)
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
    }
    
    private func setupGradient() {
        // TODO: 디자인가이드 0.7 기준으로 그라디언트 색상 기준이 없음 추후 확인필요, 하기 컬러는 에셋에 등록된게 아닌 피그마 기준으로 작성
        gradientLayer.colors = [
            UIColor(
                red:   43.0 / 255.0,
                green: 44.0 / 255.0,
                blue:  47.0 / 255.0,
                alpha: 0.0
            ).cgColor,
            UIColor(
                red:   43.0 / 255.0,
                green: 44.0 / 255.0,
                blue:  47.0 / 255.0,
                alpha: 0.762712
            ).cgColor,
            UIColor(
                red:   43.0 / 255.0,
                green: 44.0 / 255.0,
                blue:  47.0 / 255.0,
                alpha: 1.0
            ).cgColor
        ]

        // 2) 위치 배열 (0.0 ~ 1.0)
        gradientLayer.locations = [0.0, 0.4432, 0.6857]

        // 3) 방향 설정 (180deg → top(0,0) → bottom(1,1)의 중간 x=0.5)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1.0)

        // 4) 레이어 삽입
        mainImageView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupGestureRecognizers() {
        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePanGesture(_:))
        )
        panGesture.delegate = self
        panGesture.cancelsTouchesInView = false
        contentView.addGestureRecognizer(panGesture)

        // 버튼 하이라이트 이벤트 설정
        bottomButton.adjustsImageWhenHighlighted = false
        bottomButton.addTarget(self, action: #selector(didTouchDown),   for: .touchDown)
        bottomButton.addTarget(self, action: #selector(didTouchRelease), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return false
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            NotificationCenter.default.post(name: Notification.Name.LZSOriginalScrollDidBegin, object: nil)
        case .ended, .cancelled:
            NotificationCenter.default.post(name: Notification.Name.LZSOriginalScrollDidEnd, object: nil)
        default:
            break
        }
    }
    
    @objc private func didTouchDown() {
        delegate?.tappedBottomButton(isAlreadyOpened: self.isAlreadyOpened, title: self.title)
        
        UIView.animate(withDuration: 0.2) {
            self.bottomButton.backgroundColor = self.bottomState.backgroundColor.withAlphaComponent(0.7)
        }
    }

    @objc private func didTouchRelease() {
        UIView.animate(withDuration: 0.2) {
            self.bottomButton.backgroundColor = self.bottomState.backgroundColor
        }
    }
    
    func configure(ongoing: ContentsOngoingItemEntity) {
        // TODO: 카드형 슬라이드용 매핑
        
        showAnimatedGradientSkeleton(isPlaceholder: true)
    }
    
    func configure(curation: ContentsCurationItemEntity) {
        // TODO: 카드형 슬라이드용 매핑
        
        showAnimatedGradientSkeleton(isPlaceholder: true)
    }
    
    func configure(banner: ContentsBannerItemEntity) {
        // TODO: 카드형 슬라이드용 매핑
        
        title = banner.bannerTitle

        let bannerImagePathUrl = URL(string: banner.bannerImagePath)
        let titleImagUrl = URL(string: banner.titleImagePath ?? "")
        
        mainImageView.kf.setImage(with: bannerImagePathUrl)
        titleImageView.kf.setImage(with: titleImagUrl)
        scriptLabel.text = banner.synopsis
        
        if banner.isShow {
            setBottomContainer(state: .play)
        } else {
            setBottomContainer(state: .alarm(date: Date()))
        }
        let tagType: TagType = {
            switch (banner.contractType ?? "").trimmingCharacters(in: .whitespacesAndNewlines).uppercased() {
            case "LEZHIN_ORIGINAL":  return .lezhin
            case "BOMTOON_ORIGINAL": return .bomtoon
            case "GENERAL_ORIGINAL": return .original
            default:                 return .onlyTag  // nil, "OTHERS", 그 외
            }
        }()
        
        makeSignatureInfoView(titleText: banner.signatureText ?? "", tagType: tagType)
        showAnimatedGradientSkeleton(isPlaceholder: false)
    }
    
    
    
    func configure(_ data: HomeSectionEntity) {
        showAnimatedGradientSkeleton(isPlaceholder: data.isPlaceholder)
    }
    
    func showAnimatedGradientSkeleton(isPlaceholder: Bool) {
        if isPlaceholder {
            showAnimatedGradientSkeleton()
        } else {
            hideSkeleton()
        }
    }
    
}
