//
//  UseageCell.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/23/25.
//


import UIKit
import SnapKit

final class UsageCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 16)
        label.textColor = .white
        label.lineBreakMode = .byTruncatingTail
        // 제목은 스스로 줄어들도록 우선순위 낮춤
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private let coinPlusMinusLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardSemiBold(size: 16)
        label.textColor = .white
        // 금액 부호는 고정 크기를 유지
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private let coinView: LZSnackCoinInfoView = {
        let view = LZSnackCoinInfoView()
        // 코인 뷰도 크기 변형 방지
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.setContentHuggingPriority(.required, for: .horizontal)
        return view
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 13)
        label.textColor = UIColor(.foregroundSubtler)
        return label
    }()
    
    private let expiredLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 13)
        label.textColor = UIColor(.foregroundBrand)
        return label
    }()
    
    private var expiredHeightConstraint: Constraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        
        
        contentView.addSubview(expiredLabel)
        expiredLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            expiredHeightConstraint = make.height.equalTo(20).constraint
        }
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(coinPlusMinusLabel)
        contentView.addSubview(coinView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(expiredLabel.snp.bottom)
            make.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualTo(coinPlusMinusLabel.snp.leading).offset(-8)
        }
        
        coinPlusMinusLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalTo(coinView.snp.leading).offset(2)
            make.width.equalTo(11)
        }
        
        coinView.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(22)
        }
        
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().inset(16)
        }
        
    }
    
    func configure(_ item: PurchaseHistoryEntity) {
        // 텍스트 세팅
        titleLabel.text = item.title
        
        let randomBool = Bool.random()
        
        if randomBool {
            expiredLabel.text = "기만만료"
            coinPlusMinusLabel.text = "+"
        } else {
            expiredLabel.text = ""
            coinPlusMinusLabel.text = "-"
        }
        
        dateLabel.text = "2025.04.29"
        coinView.setCoinText("1000")

        // 높이 조절: 텍스트가 nil 또는 빈 문자열이면 0, 아니면 20
        let newHeight = (expiredLabel.text?.isEmpty ?? true) ? 0 : 20
        expiredHeightConstraint.update(offset: newHeight)
        
        expiredLabel.setLineHeight(20)
        titleLabel.setLineHeight(26)
        dateLabel.setLineHeight(16)

        // 레이아웃 반영
        contentView.layoutIfNeeded()
    }
    
}
