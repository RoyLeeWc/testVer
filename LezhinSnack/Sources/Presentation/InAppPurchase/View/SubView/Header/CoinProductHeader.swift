//
//  CoinProductHeader.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/30/25.
//

import UIKit
import SnapKit


protocol LezhinCoinChargeDelegate: AnyObject {
    func didTapCoinChargeButton()
}


// height 48
final class CoinProductHeader: UICollectionReusableView {
    
    weak var delegate: LezhinCoinChargeDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.pretendardMedium(size: 24)
        label.textColor = .white
        label.numberOfLines = 2
        label.text = "충전소_코인충전_헤더_타이틀".localized
        label.setLineHeight(34)
        
        return label
    }()
    
    private let currentUserCoinTitleLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.pretendardRegular(size: 13)
        label.textColor = UIColor(.foregroundSubtler)
        label.text = "충전소_코인충전_헤더_보유코인_타이틀".localized
        
        return label
    }()
    
    let currentUserCoinView: LZSnackCoinInfoView = {
        let coinInfoView = LZSnackCoinInfoView()
        coinInfoView.coinInfoLabel.textColor = UIColor(.foregroundSubtler)
        coinInfoView.coinInfoLabel.font = UIFont.pretendardRegular(size: 13)
        coinInfoView.setCoinImageSize(size: CGSize(width: 13.3, height: 13.3))
        return coinInfoView
    }()
    
    
    let lezinCoinChargeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        // 1) 기본 Configuration 생성
        var config = UIButton.Configuration.plain()
        
        // 2) 왼쪽 아이콘 리사이즈(필요하다면) 후 설정
        if let originalImage = UIImage(named: "ic_lezhin_small"),
           let resizedImage = originalImage.resized(to: CGSize(width: 14, height: 14)) {
            config.image = resizedImage
        }
        config.imagePadding = 6
        
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 7,     // 위쪽 여백 (필요하다면 조정)
            leading: 12,
            bottom: 7,  // 아래쪽 여백 (필요하다면 조정)
            trailing: 8
        )

        // 3) AttributedString으로 텍스트 + 오른쪽 아이콘 설정
        let titleText = "충전소_레진코인충전_버튼_타이틀".localized
        let attributed = NSMutableAttributedString(string: titleText)
        let fullRange = NSRange(location: 0, length: attributed.length)
        
        // 3-1) 텍스트 색상을 흰색으로 지정
        attributed.addAttribute(
            .foregroundColor,
            value: UIColor.white,
            range: fullRange
        )
        
        attributed.addAttribute(
            .font,
            value: UIFont.pretendardSemiBold(size: 13),
            range: fullRange
        )

        // 3-2) 텍스트 뒤에 공백 추가
        attributed.append(NSAttributedString(string: " "))

        // 3-3) NSTextAttachment으로 오른쪽 아이콘 추가
        let rightAttachment = NSTextAttachment()
        rightAttachment.image = UIImage(named: "ic_chevron_right_white")
        rightAttachment.bounds = CGRect(x: 0, y: -4, width: 14, height: 14)
        attributed.append(NSAttributedString(attachment: rightAttachment))

        // 3-4) Configuration에 최종 AttributedString 할당
        config.attributedTitle = AttributedString(attributed)

        // 4) Configuration 적용
        button.configuration = config

        // 5) 버튼 배경·테두리 설정
        button.backgroundColor = .clear
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(.borderDefault).cgColor

        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(34)
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().offset(-12)
        }
        
        addSubview(currentUserCoinTitleLabel)
        currentUserCoinTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        
        addSubview(currentUserCoinView)
        currentUserCoinView.snp.makeConstraints { make in
            make.centerY.equalTo(currentUserCoinTitleLabel)
            make.leading.equalTo(currentUserCoinTitleLabel.snp.trailing).offset(2)
        }
        
        addSubview(lezinCoinChargeButton)
        lezinCoinChargeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLabel)
            make.height.equalTo(32)
        }
        
        lezinCoinChargeButton.addTarget(self, action: #selector(didTapLezinCoinChargeButton), for: .touchUpInside)
        
    }
    
    @objc private func didTapLezinCoinChargeButton() {
        delegate?.didTapCoinChargeButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
