//
//  WatchHistoryHeaderView.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/15/25.
//

import UIKit
import SnapKit

protocol WatchHistoryHeaderViewDelegate: AnyObject {
    func watchHistoryHeaderViewDidTapMore(_ watchHistoryHeaderView: WatchHistoryHeaderView)
}

// height 48
final class WatchHistoryHeaderView: UICollectionReusableView {
    
    weak var delegate: WatchHistoryHeaderViewDelegate?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.pretendardSemiBold(size: 18)
        label.textColor = .white
        label.numberOfLines = 2
        
        label.text = "watchHistoryHeaderTitle".dynamicLocalized
        
        return label
    }()
    
    let moreView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    
    let moreLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.pretendardMedium(size: 13)
        label.textColor = UIColor(.whiteOpacity58)
        
        label.text = "watchHistoryHeaderMoreButtonTitle".dynamicLocalized
        
        return label
    }()
    
    let moreIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ic_chevron_right"))
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(moreView)
        
        moreView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-8)
            make.width.equalTo(32)
        }
        
        moreView.addSubview(moreLabel)
        moreView.addSubview(moreIconView)
        
        moreView.isUserInteractionEnabled = true
        let moreViewTap = UITapGestureRecognizer(target: self, action: #selector(moreViewTapped(_:)))
        moreView.addGestureRecognizer(moreViewTap)
        
        moreIconView.snp.makeConstraints { make in
            make.centerY.trailing.equalToSuperview()
            make.width.height.equalTo(14)
        }
        
        moreLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalTo(moreIconView.snp.leading)
        }
        
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.bottom.greaterThanOrEqualToSuperview().offset(-8)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalTo(moreView.snp.leading).offset(-12)
        }
        
    }
    
    @objc private func moreViewTapped(_ sender: UITapGestureRecognizer) {
        delegate?.watchHistoryHeaderViewDidTapMore(self)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
