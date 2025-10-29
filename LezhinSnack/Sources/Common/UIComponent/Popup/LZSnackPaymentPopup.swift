//
//  LZSnackPaymentPopup.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/27/25.
//

import UIKit
import SnapKit


enum ProductType {
    case subscription
    case coin
}

// 어디가 코인 행인지 판별 키워드
private let coinRowKeywords = ["코인", "coin"]

private func isCoinRow(_ label: String) -> Bool {
    coinRowKeywords.contains { label.localizedCaseInsensitiveContains($0) }
}
/// 결제 처리 내역 팝업
final class LZSnackPaymentPopup: BasePopupView {
    // MARK: - 크기 재정의
    private let popupWidthValue: CGFloat
    private let popupHeightValue: CGFloat
    
    override var popupWidth: CGFloat { popupWidthValue }
    override var popupHeight: CGFloat { popupHeightValue }
    
    // MARK: - UI 컴포넌트
    private let closeButton: UIButton = {
        let button = UIButton(type: .custom)
        let closeImage = UIImage(named: "ic_close")?.resized(to: CGSize(width: 24, height: 24))
        button.setImage(closeImage, for: .normal)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .pretendardBold(size: 18)
        label.textColor = .white
        return label
    }()

    private let infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillProportionally
        return stack
    }()
    
    // MARK: - 핸들러 & 데이터
    private var closeHandler: (() -> Void)?
    private let showsCloseButton: Bool
    private let details: [(label: String, value: String)]

    // MARK: - 초기화
    init(
        width: CGFloat = 300,
        height: CGFloat = 260,
        title: String,
        details: [(String, String)],
        productType: ProductType,
        showsCloseButton: Bool = false,
        closeHandler: (() -> Void)? = nil
    ) {
        self.popupWidthValue = width
        self.popupHeightValue = height
        self.details = details.map { (label: $0.0, value: $0.1) }
        self.showsCloseButton = showsCloseButton
        self.closeHandler = closeHandler
        super.init(frame: .zero)
        titleLabel.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 레이아웃
    override func setupContentView() {
        contentView.backgroundColor = UIColor(.backgroundOverlay)
        contentView.layer.cornerRadius = 4
        
        // Title
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(24)
        }
        titleLabel.setLineHeight(24, alignment: .center)
        
        // Info Stack
        contentView.addSubview(infoStackView)
        infoStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        // 세부 항목 추가
        details.forEach { item in
            let row = makeRow(label: item.label, value: item.value)
            infoStackView.addArrangedSubview(row)
        }
        
        // Close Button
        if showsCloseButton {
            contentView.addSubview(closeButton)
            closeButton.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(12)
                make.trailing.equalToSuperview().offset(-12)
                make.width.height.equalTo(24)
            }
            closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        }
    }
    
    @objc private func didTapCloseButton() {
        dismissPopup()
        closeHandler?()
    }
    
    private let whiteFontItems = ["결제 구분", "결제금액", "결제주기", "멤버십 구분" ]
    
    // MARK: - Row 생성
    private func makeRow(label: String, value: String) -> UIStackView {
        // 1) Key 레이블
        let keyLabel = UILabel()
        keyLabel.font = .pretendardRegular(size: 14)
        keyLabel.textColor = UIColor(.foregroundSubtler)
        keyLabel.text = label
        keyLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        // 2) Value 뷰 결정
        let valueView: UIView
        if label.contains("코인") {
            let coinView = LZSnackCoinInfoView()
            coinView.coinInfoLabel.font = .pretendardRegular(size: 14)
            coinView.setCoinText(value)
            // intrinsic size 유지
            coinView.setContentHuggingPriority(.required, for: .horizontal)
            valueView = coinView
        } else {
            let valueLabel = UILabel()
            valueLabel.font = .pretendardRegular(size: 14)
            valueLabel.textAlignment = .right
            valueLabel.text = value
            // intrinsic size 유지
            if whiteFontItems.contains(label) {
                valueLabel.textColor = UIColor(.white)
            } else {
                valueLabel.textColor = UIColor(.foregroundSubtler)
            }
            
            valueLabel.setContentHuggingPriority(.required, for: .horizontal)
            valueView = valueLabel
            
        }

        // 3) Spacer 뷰: 남은 공간을 채워서 valueView를 오른쪽 끝에 고정
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // 4) 스택뷰에 순서대로 담기
        let row = UIStackView(arrangedSubviews: [keyLabel, spacer, valueView])
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .fill     // spacer가 남은 영역을 채우도록
        row.spacing = 8               // 키-스페이서, 스페이서-값 사이 간격
        return row
    }
}
