
//
//  PaymentCell.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/23/25.
//


import UIKit
import SnapKit

final class PaymentCell: UICollectionViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 16)
        label.textColor = .white
        label.lineBreakMode = .byTruncatingTail
        // 제목은 스스로 줄어들도록 우선순위 낮춤
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 13)
        label.textColor = UIColor(.foregroundSubtler)
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 16)
        label.textColor = .white
        label.lineBreakMode = .byTruncatingTail
        // 제목은 스스로 줄어들도록 우선순위 낮춤
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        
        
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(26)
        }
        
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().inset(16)
        }
        
        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLabel)
        }
        
    }
    
    func configure(_ item: PaymentHistoryEntity) {
        // 텍스트 세팅
        titleLabel.text = item.title
        
        let randomBool = Bool.random()
        
        if item.isCoinProduct {
            if randomBool {
                titleLabel.text = "월간 구독"
                priceLabel.text = "KRW 9,900"
            } else {
                titleLabel.text = "연간 구독"
                priceLabel.text = "KRW 22,900"
            }
        } else {
            titleLabel.text = "코인 충전"
            priceLabel.text = "KRW 4,900"
        }
        
        dateLabel.text = "2025.04.29"

        titleLabel.setLineHeight(26)
        dateLabel.setLineHeight(16)

        // 레이아웃 반영
        contentView.layoutIfNeeded()
    }
    
}
