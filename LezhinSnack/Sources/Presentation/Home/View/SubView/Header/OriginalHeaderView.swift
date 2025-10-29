//
//  OriginalHeaderView.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/16/25.
//

import UIKit


// Height: 80
final class OriginalHeaderView: UICollectionReusableView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.pretendardSemiBold(size: 18)
        label.textColor = .white
        
        label.text = "originalHeaderTitle".dynamicLocalized
        
        label.numberOfLines = 0
        
        return label
    }()
    
    
    let originalLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "snack_original_logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
               
        addSubview(titleLabel)
        addSubview(originalLogoImageView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(20)
            make.bottom.greaterThanOrEqualToSuperview().offset(-8)
            make.leading.equalToSuperview().inset(20)
        }
        
        
        originalLogoImageView.snp.makeConstraints { make in
            make.width.equalTo(88)
            make.height.equalTo(36)
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(titleLabel)
        }
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
