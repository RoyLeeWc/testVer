//
//  ShopFooterCell.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/30/25.
//


import UIKit
import SnapKit

final class ShopFooterCell: UICollectionViewCell {
    
    
    private let noticeTtleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendardBold(size: 14)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 0
        label.text = "충전소_푸터_타이틀".localized
        return label
    }()
    
    private let noticeDescLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendardRegular(size: 13)
        label.textColor = UIColor.foregroundSubtler
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setupUI()}
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        
        contentView.addSubview(noticeTtleLabel)
        noticeTtleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        
        contentView.addSubview(noticeDescLabel)
        noticeDescLabel.snp.makeConstraints { make in
            make.top.equalTo(noticeTtleLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    
    func configure(with entity: ShopFooterEntity) {
        noticeDescLabel.setIconBulletList(
            lines: entity.texts,
            iconName: "ic_bullet",           // Assets.xcassets에 등록된 아이콘 이름
            iconSize: CGSize(width: 4, height: 18),
            baselineOffset: -3,
            font: UIFont.pretendardRegular(size: 13),
            textColor: UIColor.foregroundSubtler,
            lineSpacing: 2,
            paragraphSpacing: 2
        )
    }
}
