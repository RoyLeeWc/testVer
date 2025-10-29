//
//  CoinProductCell.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/30/25.
//


import UIKit
import SnapKit

final class CoinProductCell: UICollectionViewCell {
    
    private let coinView: LZSnackCoinInfoView = {
        let view = LZSnackCoinInfoView()
        
        view.coinInfoLabel.textColor = .white
        view.coinInfoLabel.font = .pretendardBold(size: 16)
        
        return view
    }()
    
    private let coinPricelabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .white
        label.font = .pretendardMedium(size: 13)
        
        return label
    }()
    
    private let coinDiscountLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = UIColor.foregroundSubtler
        label.font = .pretendardRegular(size: 12)
        
        return label
    }()
    
    private let coinSalePercentageLabel: LZSnackPaddingLabel = {
        let label = LZSnackPaddingLabel()
        label.textInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        
        label.textColor = .white
        label.font = .pretendardMedium(size: 11)
        label.backgroundColor = UIColor(.fillBrand)
        
        label.layer.cornerRadius = 4

        label.layer.maskedCorners = [.layerMinXMaxYCorner]

        label.clipsToBounds = true
        
        return label
    }()
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setupUI()}
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI() {
        
        contentView.roundCorners(cornerRadius: 8)
        contentView.backgroundColor = UIColor(.backgroundRaisedHigh)
        
        contentView.addSubview(coinView)
        coinView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(12)
            make.height.equalTo(24)
        }
        
        contentView.addSubview(coinPricelabel)
        coinPricelabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.top.equalTo(coinView.snp.bottom).offset(5)
        }
        
        contentView.addSubview(coinDiscountLabel)
        coinDiscountLabel.snp.makeConstraints { make in
            make.leading.equalTo(coinPricelabel.snp.trailing).offset(4)
            make.centerY.equalTo(coinPricelabel)
        }
        
        contentView.addSubview(coinSalePercentageLabel)
        coinSalePercentageLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(17)
        }
        
    }
    
    
    func configure(with entity: CoinProductEntity ) {
        
        let originalPriceInt = Int(entity.originalPrice)
        let discountInt = Int(entity.salePrice)
        let salePersentageInt = Int(entity.salePersentage)
        
        coinView.setCoinText(entity.coinValue)
        coinPricelabel.text = "충전소_가격기호".localized(with: originalPriceInt)
        
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
        coinDiscountLabel.attributedText = attributedString
        
        if entity.isFirstPurchase {
            coinSalePercentageLabel.text = "\("충전소_코인충전_첫충전할인".localized(with: salePersentageInt))%"
        } else {
            coinSalePercentageLabel.text = "\(salePersentageInt)%"
        }
        
    }
}
