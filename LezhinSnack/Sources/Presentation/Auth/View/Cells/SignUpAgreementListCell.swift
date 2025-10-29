//
//  SignUpAgreementLisCell.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/18/25.
//

import UIKit
import SnapKit





final class SignUpAgreementListCell: UICollectionViewCell {
    
    var onDetailTap: (() -> Void)?
    let cellCheckBox = {
        let checkBox = LZSnackCheckBox()
        
        checkBox.checkedImage = UIImage(named: "ic_checked_white")?.withRenderingMode(.alwaysOriginal)
        checkBox.uncheckedImage = UIImage(named: "ic_checked")?.withRenderingMode(.alwaysOriginal)
        checkBox.partialImage = UIImage(named: "ic_checked")?.withRenderingMode(.alwaysOriginal)
        
        return checkBox
    }()
    
    
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendardSemiBold(size: 14)
        label.textColor = .white
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendardRegular(size: 13)
        label.textColor = UIColor(.foregroundSubtler)
        return label
    }()
    
    // MARK: - Detail Button (24x24 icon only)
    let detailButton: UIButton = {
        let button = UIButton(type: .system)
        let icon = UIImage(named: "ic_chevron_right_white")?.withRenderingMode(.alwaysOriginal)
        button.setImage(icon, for: .normal)
        button.contentEdgeInsets = .zero
        button.contentHorizontalAlignment = .center
        button.tintColor = .clear
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()  // 셀 내부 뷰들을 추가 및 제약조건 설정
        
    }
    
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                cellCheckBox.setState(.checked)
            } else {
                cellCheckBox.setState(.unchecked)
            }
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:)는 지원하지 않습니다. 코드 기반으로 구현해 주세요.")
    }
    
    
    func setupUI() {
        
        backgroundColor = UIColor(.backgroundDefault)
        contentView.addSubview(cellCheckBox)
        
        
        cellCheckBox.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.width.height.equalTo(24)
            make.top.equalToSuperview().offset(16)
        }
        
        cellCheckBox.isUserInteractionEnabled = false
        
        contentView.addSubview(detailButton)
        detailButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.size.equalTo(24)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(cellCheckBox)
            make.leading.equalTo(cellCheckBox.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualTo(detailButton.snp.leading).offset(-8)
        }
        
        contentView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(titleLabel)
            make.bottom.equalToSuperview().inset(16)
        }
        
        detailButton.addTarget(self, action: #selector(detailTapped), for: .touchUpInside)
        
    }
    
    @objc private func detailTapped() {
        onDetailTap?()
    }
    
    
    func configure(with entity: AgreementEntity) {
        let title = entity.title
        let typeText: String
        switch entity.agreementType {
        case .required:
            typeText = " (\("이용약관_필수_타이틀".localized))"
        case .optional:
            typeText = " (\("이용약관_선택_타이틀".localized))"
        }

        let fullString = title + typeText
        let attributedString = NSMutableAttributedString(string: fullString)
        let titleRange = NSRange(location: 0, length: title.count)
        let typeRange = NSRange(location: title.count, length: typeText.count)

        // Title: white, semi-bold
        attributedString.addAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.pretendardSemiBold(size: 14)
        ], range: titleRange)

        // Type tag: subtler gray, regular font
        attributedString.addAttributes([
            .foregroundColor: UIColor(.foregroundSubtler),
            .font: UIFont.pretendardRegular(size: 14)
        ], range: typeRange)

        titleLabel.attributedText = attributedString
        
        
        if let subtitle = entity.subtitle {
            subtitleLabel.text = subtitle
        }
        
    }
    
}
