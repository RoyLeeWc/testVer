//
//  GenreHeaderView.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/16/25.
//

import UIKit


// Height: 56
final class GenreHeaderView: UICollectionReusableView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.pretendardSemiBold(size: 18)
        label.textColor = .white
        
        label.text = "originalHeaderTitle".dynamicLocalized
        
        label.numberOfLines = 0
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        
        
        titleLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(20)
            make.bottom.greaterThanOrEqualToSuperview().offset(-8)
            make.leading.equalToSuperview().inset(20)
        }
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
