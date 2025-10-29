//
//  BottomSheetMembershipProductCell.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/30/25.
//

import UIKit
import SnapKit

final class BottomSheetMembershipProductCell: UICollectionViewCell {
    
    private let membershipProductNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendardSemiBold(size: 13)
        label.textColor = .white
        return label
    }()
    
    private let membershipProductPriceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendardMedium(size: 12)
        label.textColor = .white
        return label
    }()
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setupUI()}
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI() {
        
        contentView.backgroundColor = UIColor(.backgroundRaisedHigh)
        contentView.roundCorners(cornerRadius: 8)
        
        contentView.addSubview(membershipProductNameLabel)
        membershipProductNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
        }
        
        contentView.addSubview(membershipProductPriceLabel)
        membershipProductPriceLabel.snp.makeConstraints { make in
            make.top.equalTo(membershipProductNameLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(16)
        }
        
    }
    
    
    func configure(with entity: MembershipProductEntity) {
        
        let originalPriceInt = Int(entity.originalPrice)
        let discountInt = Int(entity.salePrice)
        
        membershipProductPriceLabel.text = "충전소_가격기호".localized(with: originalPriceInt)
        
        switch entity.membershipType {
        case "annualSubscription":
            membershipProductNameLabel.text = "충전소_연간멤버십_타이틀".localized
        case "monthlySubscription":
            membershipProductNameLabel.text = "충전소_월간멤버십_타이틀".localized
        default:
            break
        }
        
        if entity.isBestProducts {
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor(.borderBrandStronger).cgColor
            
            let paddingLabel = LZSnackPaddingLabel()
            paddingLabel.textInsets = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
            paddingLabel.textColor = .white
            paddingLabel.font = .pretendardMedium(size: 12)
            paddingLabel.backgroundColor = .fillBrand
            paddingLabel.text = "BEST"
            
            paddingLabel.roundCorners(cornerRadius: 4)
            
            self.addSubview(paddingLabel)
            paddingLabel.snp.makeConstraints { make in
                make.centerY.equalTo(contentView.snp.top)
                
                // 2) 레이블의 오른쪽 모서리를 contentView의 오른쪽에서 10pt 안쪽으로 배치
                make.trailing.equalToSuperview().offset(-10)
            }
        }
    }
    
}

