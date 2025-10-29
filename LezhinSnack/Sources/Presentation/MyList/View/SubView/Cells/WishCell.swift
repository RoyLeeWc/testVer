//
//  WishCell.swift
//  LezhinSnack
//
//  Created by 신진우 on 4/20/25.
//
import UIKit
import SnapKit

final class WishCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    var isEditingMode: Bool = false {
        didSet {
            updateEditingMode()
        }
    }
    
    private var progressHeightConstraint: Constraint?
    
    private func syncSelectionUI() {
        if isEditingMode {
            checkBox.setState(isSelected ? .checked : .unchecked)
            thumbnailImageView.alpha = isSelected ? 1.0 : 0.3
        } else {
            checkBox.setState(.unchecked)
            thumbnailImageView.alpha = 1.0      // 일반 모드: 항상 진하게
        }
    }
    
    override var isSelected: Bool {
        didSet { syncSelectionUI() }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isSelected = false
        syncSelectionUI()
    }
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 14)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    
    private let checkBox: LZSnackCheckBox = {
        let checkBox = LZSnackCheckBox()
        checkBox.isUserInteractionEnabled = false
        return checkBox
    }()
    
    
    
    func updateEditingMode() {
        // 체크박스
        checkBox.isHidden = !isEditingMode

        // progressView 높이 0 또는 4
        let height: CGFloat = isEditingMode ? 0 : 4
        progressHeightConstraint?.update(offset: height)

        // 셀 dimming
        thumbnailImageView.alpha = isEditingMode
            ? (isSelected ? 1.0 : 0.3)
            : 1.0

        // 즉시 레이아웃 반영
        contentView.layoutIfNeeded()
    }
    
    private func setupUI() {
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(20)
        }
        
        contentView.addSubview(thumbnailImageView)
        thumbnailImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).offset(-8)
        }
        
        thumbnailImageView.roundCorners(cornerRadius: 4)
        
        contentView.addSubview(checkBox)
        checkBox.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.width.height.equalTo(24)
            make.trailing.equalToSuperview().inset(6)
        }
        
        checkBox.isHidden = true
        
    }
    
    func configure(with entity: WishContentItemEntity) {
        thumbnailImageView.kf.setImage(with: URL(string: entity.thumbnailUrl))
        titleLabel.text = entity.title
    }
    
}
