//
//  BottomSheetMembershipProductHeader.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/30/25.
//


import UIKit
import SnapKit


// height 66
final class BottomSheetMembershipProductHeader: UICollectionReusableView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.pretendardSemiBold(size: 16)
        label.textColor = .white
        label.numberOfLines = 2
        
        label.text = "충전소_멤버십구독_헤더_타이틀".localized
        
        return label
    }()
    
    
    let moreLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.pretendardMedium(size: 14)
        label.textColor = .white
        
        label.text = "충전소_멤버십구독_헤더_더보기".localized
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(titleLabel)
            
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(22)
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        addSubview(moreLabel)
        
        moreLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).offset(-16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
