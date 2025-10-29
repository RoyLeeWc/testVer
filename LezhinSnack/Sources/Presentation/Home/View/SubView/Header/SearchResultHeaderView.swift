//
//  SearchResultHeaderView.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/28/25.
//


import UIKit
import SnapKit


final class SearchResultHeaderView: UICollectionReusableView {
    
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 13)
        label.textColor = .white
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardSemiBold(size: 13)
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.text = "검색결과"
        
        
        self.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
        }
        
        
        countLabel.text = "0건"
    }
    
    
    func setCount(_ count: Int) {
        if count <= 0 {
            self.countLabel.isHidden = true
            self.titleLabel.isHidden = true
        } else {
            self.countLabel.isHidden = false
            self.titleLabel.isHidden = false
            self.countLabel.text = "\(count)건"
        }
    }
    
}
