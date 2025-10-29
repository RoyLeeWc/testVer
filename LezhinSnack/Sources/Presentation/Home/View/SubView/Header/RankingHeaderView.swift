//
//  PopularHeaderView.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/15/25.
//

import UIKit
import SnapKit

// Height 64
final class RankingHeaderView: UICollectionReusableView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.pretendardSemiBold(size: 18)
        label.textColor = .white
        label.numberOfLines = 2
        
        label.text = "mostViewed".dynamicLocalized
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.bottom.greaterThanOrEqualToSuperview().offset(-12)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
        }
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

