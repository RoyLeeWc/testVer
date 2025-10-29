//
//  MembershipProductHeader.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/30/25.
//


import UIKit
import SnapKit


// height 66
final class MembershipProductHeader: UICollectionReusableView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.pretendardMedium(size: 24)
        label.textColor = .white
        label.numberOfLines = 2
        
        label.text = "충전소_멤버십구독_헤더_타이틀".localized
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(titleLabel)
            
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(32)
            make.height.equalTo(34)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().offset(-12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
