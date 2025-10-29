//
//  MainBannerCell.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/6/25.
//

import UIKit
import SnapKit
import SkeletonView

final class MainBannerCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    
    private let imageView: UIImageView = {
        let uiImageView = UIImageView()
        uiImageView.contentMode = .scaleAspectFill
        uiImageView.clipsToBounds = true
        return uiImageView
    }()
    
    private let signatureInfoView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    private let gradientLayer = CAGradientLayer()   // <- 레이어 보관
    private let gradientLayerView = UIView()
    
    private let keywordTextView: UITextView = {
        let keywordTextView = UITextView()
        keywordTextView.isScrollEnabled = false
        keywordTextView.textAlignment = .center
        keywordTextView.backgroundColor = .clear
        keywordTextView.isEditable = false
        keywordTextView.isSelectable = false
        
        keywordTextView.isHidden = true
        
        return keywordTextView
    }()
    
    
    private let bannerTitleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.isHidden = true
        return imageView
    }()
    
    
    private let originalContentTagView: UIView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    
    private let tagImageView = UIImageView(image: UIImage(named: "original_word"))
    private let unionImageView = UIImageView(image: UIImage(named: "ic_tag_snack"))
    private let rightImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "sig_right_image"))
        imageView.isHidden = true
        return imageView
    }()
    
    private let infoLabel = {
        let infoLabel = UILabel()
        infoLabel.textAlignment = .left
        infoLabel.lineBreakMode = .byTruncatingTail
        infoLabel.numberOfLines = 3
        infoLabel.backgroundColor = .clear
        infoLabel.isHidden = true
        return infoLabel
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()  // 셀 내부 뷰들을 추가 및 제약조건 설정
        setupGestureRecognizers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:)는 지원하지 않습니다. 코드 기반으로 구현해 주세요.")
    }
    
    private func setupGestureRecognizers() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        // 스크롤 등의 다른 터치 이벤트가 계속 전달되도록 설정
        panGesture.cancelsTouchesInView = false
        contentView.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            NotificationCenter.default.post(name: Notification.Name.LZSMainBannerScrollDidBegin, object: nil)
        case .ended, .cancelled:
            NotificationCenter.default.post(name: Notification.Name.LZSMainBannerScrollDidEnd, object: nil)
        default:
            break
        }
    }
    
    // 다른 제스처 인식기와 동시에 인식되도록 허용
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    private func setupUI() {
        
//        isSkeletonable = true
//        contentView.isSkeletonable = true
        
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.addSubview(gradientLayerView)
        gradientLayerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientLayerView.layer.addSublayer(gradientLayer)

        // 원하는 색으로 (예: 아래쪽으로 짙어지는 어두운 그라데이션)

        gradientLayer.colors = [
            UIColor(red: 0.04, green: 0.04, blue: 0.05, alpha: 0).cgColor,
            UIColor(red: 0.04, green: 0.04, blue: 0.05, alpha: 1).cgColor
        ]
        gradientLayer.locations = [0.7, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1)
        
        contentView.addSubview(signatureInfoView)
        signatureInfoView.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.leading.equalTo(imageView.snp.leading).inset(20)
            make.trailing.equalTo(imageView.snp.trailing).inset(20)
            make.bottom.equalToSuperview()
        }
        signatureInfoView.roundCorners(cornerRadius: 30)
        signatureInfoView.backgroundColor = UIColor.init(hexString: "#861E34")
        
        contentView.addSubview(keywordTextView)
        
        keywordTextView.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(signatureInfoView.snp.top).offset(-16)
        }
        
        contentView.addSubview(bannerTitleImageView)
        bannerTitleImageView.snp.makeConstraints { make in
            make.height.equalTo(80)
            make.bottom.equalTo(keywordTextView.snp.top).offset(-16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        contentView.addSubview(originalContentTagView)
        originalContentTagView.snp.makeConstraints { make in
            make.height.equalTo(12)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(bannerTitleImageView.snp.top).offset(-16)
        }
        
        originalContentTagView.addSubview(tagImageView)
        tagImageView.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
        }
        
        
        originalContentTagView.addSubview(unionImageView)
        
        unionImageView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(12)
            make.trailing.equalTo(tagImageView.snp.leading).offset(-2)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = gradientLayerView.bounds
        CATransaction.commit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    func reset() {
        // 이전 상태 정리
        bannerTitleImageView.image = nil
        imageView.image = nil
        keywordTextView.text = ""
        rightImageView.image = nil
        infoLabel.text = ""
    }
    
    func configure(ranking: ContentsRankingItemEntity) {
        showAnimatedGradientSkeleton(isPlaceholder: true)
    }
    
    func configure(ongoing: ContentsOngoingItemEntity) {
        showAnimatedGradientSkeleton(isPlaceholder: true)
    }
    
    func configure(banner: ContentsBannerItemEntity) {

        let bannerImagePathUrl = URL(string: banner.bannerImagePath)
        let titleImagUrl = URL(string: banner.titleImagePath ?? "")
        
        if let signatureImagePath = banner.signatureImagePath {
            let signatureImageUrl = URL(string: signatureImagePath)
            rightImageView.kf.setImage(with: signatureImageUrl)
        }
        
        imageView.kf.setImage(with: bannerImagePathUrl)
        bannerTitleImageView.kf.setImage(with: titleImagUrl)

        bannerTitleImageView.isHidden = false
        imageView.isHidden = false
        keywordTextView.isHidden = false
        signatureInfoView.isHidden = false
        rightImageView.isHidden = false
        infoLabel.isHidden = false
        
        
        let attributedText = NSMutableAttributedString()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.pretendardMedium(size: 14),
            .foregroundColor: UIColor.white
        ]
        
        let keywords = banner.keywordNames
        let keywordsString = keywords.joined(separator: " · ")
        
        attributedText.append(NSAttributedString(string: keywordsString, attributes: attributes))
        keywordTextView.attributedText = attributedText
         
        
        
        
        if let signatureText = banner.signatureText {
            let tagType: TagType = {
                switch (banner.contractType ?? "").trimmingCharacters(in: .whitespacesAndNewlines).uppercased() {
                case "LEZHIN_ORIGINAL":  return .lezhin
                case "BOMTOON_ORIGINAL": return .bomtoon
                case "GENERAL_ORIGINAL": return .original
                default:                 return .onlyTag  // nil, "OTHERS", 그 외
                }
            }()
            let signatureBgColor = banner.signatureBackgroundColor
            
            if tagType == .onlyTag{
                originalContentTagView.isHidden = true
            } else {
                originalContentTagView.isHidden = false
            }
            
            
            let markTypes: [LZSnackMarkType] = {
                var seen = Set<BadgeType>()              // 타입 기준 중복 제거
                return (banner.badges ?? [])
                    .filter { seen.insert($0.type).inserted }
                    .compactMap { LZSnackMarkType(badge: $0) }   
                    .prefix(3)
                    .map { $0 }
            }()
            
            makeSignatureInfoView(infoText: signatureText,
                                  tagType: tagType,
                                  backgroundColor: signatureBgColor ?? "#861E34",
                                  markTypes: markTypes)
            
        } else {
            makeSignatureInfoView(infoText: "레진코믹스\n12주간 로맨스 TOP1 원작 웹툰",
                                  tagType: TagType.allCases.randomElement()!,
            backgroundColor: "#861E34")
        }
        
        
        
        showAnimatedGradientSkeleton(isPlaceholder: false)
    }
    
    func configure(_ data: HomeSectionEntity) {
        showAnimatedGradientSkeleton(isPlaceholder: data.isPlaceholder)
    }
    
    
    func makeSignatureInfoView(infoText: String, tagType: TagType, backgroundColor: String , markTypes: [LZSnackMarkType] = []) {
        // 기존 뷰 제거
        signatureInfoView.subviews.forEach { $0.removeFromSuperview() }
        rightImageView.removeFromSuperview()
        infoLabel.removeFromSuperview()
        
        var infoText = infoText
        
        switch tagType {
            
        case .lezhin:
            signatureInfoView.backgroundColor = UIColor.init(hexString: backgroundColor)
        case .bomtoon:
//            infoText = "봄툰\n12주간 로맨스 TOP1 원작 웹툰12주간 로맨스 TOP1 원작 웹툰12주간 로맨스 TOP1 원작 웹툰12주간 로맨스 TOP1 원작 웹툰12주간 로맨스 TOP1 원작 웹툰"
            signatureInfoView.backgroundColor = UIColor.init(hexString: backgroundColor)
        case .original:
//            infoText = "미생 김원석 감독이 디렉팅한 작품"
            signatureInfoView.backgroundColor = UIColor.init(hexString: backgroundColor)
        case .onlyTag:
            signatureInfoView.backgroundColor = .clear
            makeTagOnlySignatureInfoView(markTypes: markTypes)
            return
        }

        // 태그 아이콘 추가
        let iconContainerView = LZSUtil.makeTagView(type: tagType)
        signatureInfoView.addSubview(iconContainerView)
        iconContainerView.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.leading.equalToSuperview().inset(12)
            make.top.bottom.equalToSuperview().inset(10)
        }
        iconContainerView.roundCorners(cornerRadius: 20)

        // 오른쪽 이미지 추가
        contentView.addSubview(rightImageView)
        rightImageView.snp.makeConstraints { make in
            make.width.equalTo(142)
            make.top.equalTo(signatureInfoView.snp.top).offset(-12)
            make.bottom.equalTo(signatureInfoView.snp.bottom)
            make.trailing.equalTo(signatureInfoView.snp.trailing)
        }
        rightImageView.roundCorners(cornerRadius: 30, maskedCorners: .layerMaxXMaxYCorner)

        // infoLabel 추가
        contentView.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconContainerView.snp.trailing).offset(12)
            make.trailing.equalTo(signatureInfoView.snp.trailing).inset(58)
            make.centerY.equalTo(signatureInfoView.snp.centerY)
        }

        // 텍스트 속성 정의
        let firstLineAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.pretendardSemiBold(size: 14),
            .foregroundColor: UIColor.white
        ]
        let secondLineAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.pretendardSemiBold(size: 12),
            .foregroundColor: UIColor.white
        ]

        // infoText를 \n로 분리
        let parts = infoText.components(separatedBy: "\n")
        let firstLine = parts.first ?? ""
        let remainingLines = parts.dropFirst().joined(separator: "\n")

        // NSMutableAttributedString 구성
        let attributedText = NSMutableAttributedString(
            string: firstLine,
            attributes: firstLineAttributes
        )
        if !remainingLines.isEmpty {
            attributedText.append(
                NSAttributedString(
                    string: "\n" + remainingLines,
                    attributes: secondLineAttributes
                )
            )
        }

        infoLabel.attributedText = attributedText
        contentView.bringSubviewToFront(infoLabel)
    }
    
    
    
    private func makeTagOnlySignatureInfoView(markTypes: [LZSnackMarkType]) {

        //  스택뷰 생성
        let marksStackView = UIStackView()
        marksStackView.axis = .horizontal
        marksStackView.alignment = .center
        marksStackView.spacing = 8
        // group 너비를 내부 컨텐츠에 딱 맞추기 위해 hugging 우선순위 높임
        marksStackView.setContentHuggingPriority(.required, for: .horizontal)

        //  부모 뷰에 추가 & 중앙 제약
        signatureInfoView.addSubview(marksStackView)
        marksStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(40)    // 전체 스택뷰 높이 고정
        }

        //  마크 뷰 3개 추가
        markTypes.forEach { type in
            let markView = LZSnackMarkView(type: type,
                                       leadingTrailingInset: 11,
                                       fontSize: 13)
            markView.backgroundColor = UIColor(.fillStaticBlack)
            // 자식 뷰 높이만 고정
            markView.snp.makeConstraints { make in
                make.height.equalTo(40)
            }
            // 스택뷰가 자식 크기에 맞춰 줄어들도록 우선순위 설정
            markView.setContentHuggingPriority(.required, for: .horizontal)
            markView.roundCorners(cornerRadius: 20)
            
            marksStackView.addArrangedSubview(markView)
        }
    }
    
    
    func showAnimatedGradientSkeleton(isPlaceholder: Bool) {
        if isPlaceholder {
            showAnimatedGradientSkeleton()
        } else {
            hideSkeleton()
        }
    }
    
}
