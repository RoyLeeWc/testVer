//
//  EpisodeInfoHeader.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/30/25.
//

import UIKit
import SnapKit


//height64
final class ContentsListHeader: UICollectionReusableView {
    
    let headerTitle: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = .pretendardSemiBold(size: 14)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        self.backgroundColor = UIColor(.clear)
        
        
        addSubview(headerTitle)
        headerTitle.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(32)
            make.bottom.equalToSuperview().offset(-12)
        }

    }
    
}
