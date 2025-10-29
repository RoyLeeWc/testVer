//
//  MembershipProductCell.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/30/25.
//

import UIKit
import SnapKit

final class MembershipProductCell: UICollectionViewCell {
    
    private let membershipProductNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendardMedium(size: 14)
        label.textColor = .white
        return label
    }()
    
    private let membershipProductPriceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendardBold(size: 18)
        label.textColor = .white
        return label
    }()
    
    private let salePercentageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendardMedium(size: 20)
        label.textColor = UIColor(.foregroundBrand)
        return label
    }()
    
    private let membershipProductDiscountPriceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendardMedium(size: 14)
        label.textColor = UIColor(.foregroundSubtler)
        return label
    }()
    
    private let membershipDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendardRegular(size: 13)
        label.textColor = UIColor(.foregroundSubtler)
        label.numberOfLines = 0
        return label
    }()
    
    private let membershipIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
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
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(20)
        }
        
        contentView.addSubview(salePercentageLabel)
        salePercentageLabel.snp.makeConstraints { make in
            make.top.equalTo(membershipProductNameLabel.snp.bottom)
            make.leading.equalToSuperview().offset(20)
        }
        
        contentView.addSubview(membershipProductPriceLabel)
        membershipProductPriceLabel.snp.makeConstraints { make in
//            make.top.equalTo(membershipProductNameLabel.snp.bottom).offset(2)
            make.centerY.equalTo(salePercentageLabel)
            make.leading.equalTo(salePercentageLabel.snp.trailing).offset(4)
        }
        
        contentView.addSubview(membershipProductDiscountPriceLabel)
        membershipProductDiscountPriceLabel.snp.makeConstraints { make in
            make.top.equalTo(salePercentageLabel.snp.bottom)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(20)
        }
        
        contentView.addSubview(membershipDescriptionLabel)
        membershipDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(membershipProductDiscountPriceLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        contentView.addSubview(membershipIconImageView)
        membershipIconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-25)
            make.width.height.equalTo(81)
        }
    }
    
    
    func configure(with entity: MembershipProductEntity) {
        
        let originalPriceInt = Int(entity.originalPrice)
        let discountInt = Int(entity.salePrice)
        
        membershipProductPriceLabel.text = "충전소_가격기호".localized(with: originalPriceInt)
        
        
        let priceString = "충전소_가격기호".localized(with: discountInt)
        let attributedString = NSMutableAttributedString(string: priceString )
        let fullRange = NSRange(location: 0, length: priceString.count)
        
        // ② 취소선 속성 추가
        attributedString.addAttribute(
            .strikethroughStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: fullRange
        )
        attributedString.addAttribute(
            .strikethroughColor,
            value: UIColor.foregroundSubtler,
            range: fullRange
        )
        membershipProductDiscountPriceLabel.attributedText = attributedString
        
        
        salePercentageLabel.text = entity.salePersentage.cleanString + "%"
        
        let lines = [
            "첫 번째 항목: 중요한 정보",
            "두 번째 항목: 설명이 길어질 수도 있음",
//            "세 번째 항목: 간단 요약",
//            "네 번째 항목: 간단 요약",
//            "다선 번째 항목: 간단 요약",
        ]

        // 3) UILabel 확장 함수 호출
        membershipDescriptionLabel.setIconBulletList(
            lines: lines,
            iconName: "ic_bullet",           // Assets.xcassets에 등록된 아이콘 이름
            iconSize: CGSize(width: 4, height: 18),
            baselineOffset: -3,
            font: UIFont.pretendardRegular(size: 13),
            textColor: UIColor.foregroundSubtler,
            lineSpacing: 0,
            paragraphSpacing: 0
        )
        
        switch entity.membershipType {
        case "annualSubscription":
            membershipProductNameLabel.text = "충전소_연간멤버십_타이틀".localized
            membershipIconImageView.image = UIImage(named: "annualSubscribedBanner")
            setupNonDisccount()
        case "monthlySubscription":
            membershipProductNameLabel.text = "충전소_월간멤버십_타이틀".localized
            membershipIconImageView.image = UIImage(named: "monthlySubscribedBanner")
            setupDisccount()
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
    
    private func setupNonDisccount() {
        // 1) salePersentageLable 숨김
        salePercentageLabel.isHidden = true

        // 2) membershipProductDiscounPriceLabel 숨김 및 할인가를 “0”으로 표시
        membershipProductDiscountPriceLabel.isHidden = true
        membershipProductDiscountPriceLabel.text = "충전소_가격기호".localized(with: 0) // or 그냥 "0원"

        // 3) membershipProductPriceLabel의 제약을 부모 뷰로 재설정
        membershipProductPriceLabel.snp.remakeConstraints { make in
            make.top.equalTo(membershipProductNameLabel.snp.bottom).offset(2)
            make.leading.equalToSuperview().offset(20)
        }
        
        membershipDescriptionLabel.snp.remakeConstraints { make in
            make.top.equalTo(membershipProductPriceLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    private func setupDisccount() {
        // 1) salePersentageLable 보이기
        salePercentageLabel.isHidden = false

        // 2) membershipProductDiscounPriceLabel 보이기
        membershipProductDiscountPriceLabel.isHidden = false

        // 3) membershipProductPriceLabel 제약을 원래대로 복원
        membershipProductPriceLabel.snp.remakeConstraints { make in
            make.centerY.equalTo(salePercentageLabel)
            make.leading.equalTo(salePercentageLabel.snp.trailing).offset(4)
        }
    }
    
}

