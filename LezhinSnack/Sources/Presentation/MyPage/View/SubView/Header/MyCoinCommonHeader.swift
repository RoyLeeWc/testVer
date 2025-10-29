//
//  MyCoinCommonHeader.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/23/25.
//

import UIKit
import SnapKit


protocol MyCoinCommonHeaderDelegate: AnyObject {
    func sortButtonDidTap(header: MyCoinCommonHeader, anchor: UIView)
}


// Height 104
final class MyCoinCommonHeader: UICollectionReusableView {
    
    
    weak var delegate: MyCoinCommonHeaderDelegate?
    
    private let currentCoinInfoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.roundCorners(cornerRadius: 8)
        view.backgroundColor = UIColor(.backgroundRaisedHigh)
        return view
    }()
    
    
    private let currentCoinTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 12)
        label.textColor = UIColor(.foregroundSubtler)
        label.textAlignment = .left
        label.text = ""
        return label
    }()
    
    private let currentCoinView = LZSnackCoinInfoView()
    
    private let expiredCoinTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 12)
        label.textColor = UIColor(.foregroundSubtler)
        label.textAlignment = .left
        label.text = ""
        return label
    }()
    
    private let expiredCoinView = LZSnackCoinInfoView()
    
    
    private let sortButton: UIButton = {
        let rightImageButton = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        
        config.title = "컨텍스트메뉴_전체순".localized
        config.image = UIImage(named: "ic_chevron_down_white")
        
        config.imagePlacement = .trailing       // 이미지를 텍스트 오른쪽(trailing)에 배치
        config.imagePadding = 4                 // 텍스트와 이미지 간격을 8pt로 지정
        
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var updated = incoming
            updated.font = UIFont.pretendardMedium(size: 16)
            updated.foregroundColor = UIColor.white
            return updated
        }
        config.baseBackgroundColor = UIColor.clear
        
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        rightImageButton.configuration = config
        
        return rightImageButton
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
    
        self.addSubview(currentCoinInfoContainerView)
        currentCoinInfoContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(66)
        }
        
        currentCoinInfoContainerView.addSubview(currentCoinTitleLabel)
        currentCoinTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
        }
        
        currentCoinInfoContainerView.addSubview(currentCoinView)
        currentCoinView.snp.makeConstraints { make in
            make.top.equalTo(currentCoinTitleLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(22)
        }
        
        currentCoinInfoContainerView.addSubview(expiredCoinTitleLabel)
        expiredCoinTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(currentCoinInfoContainerView.snp.centerX)
        }

        currentCoinInfoContainerView.addSubview(expiredCoinView)
        expiredCoinView.snp.makeConstraints { make in
            make.top.equalTo(expiredCoinTitleLabel.snp.bottom).offset(4)
            make.leading.equalTo(currentCoinInfoContainerView.snp.centerX)
            make.height.equalTo(22)
        }
        
        
        self.addSubview(sortButton)
        sortButton.snp.makeConstraints { make in
            make.top.equalTo(currentCoinInfoContainerView.snp.bottom).offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        sortButton.addTarget(
            self,
            action: #selector(sortButtonDidTap(anchor:)),
            for: .touchUpInside
        )
    }
    
    @objc func sortButtonDidTap(anchor: UIView) {
        delegate?.sortButtonDidTap(header: self, anchor: anchor)
    }

    func setCoinInfoViewText() {
        currentCoinTitleLabel.text = "내코인_충전내역_헤더_보유코인".localized
        currentCoinTitleLabel.setLineHeight(16)
        currentCoinView.setCoinText("0")
        
        expiredCoinTitleLabel.text = "내코인_충전내역_헤더_7일내만료_타이틀".localized
        expiredCoinTitleLabel.setLineHeight(16)
        expiredCoinView.setCoinText("0")
    }
    
    func setCoinInfoViewText(setCoinText: String, expiredCoinText: String) {
        currentCoinTitleLabel.text = "내코인_충전내역_헤더_보유코인".localized
        currentCoinTitleLabel.setLineHeight(16)
        currentCoinView.setCoinText(setCoinText)
        
        expiredCoinTitleLabel.text = "내코인_충전내역_헤더_7일내만료_타이틀".localized
        expiredCoinTitleLabel.setLineHeight(16)
        expiredCoinView.setCoinText(expiredCoinText)
    }
    
    func updateSortTitle(_ option: MyCoinSortOption) {
        sortButton.setTitle(option.displayName, for: .normal)
    }
}
