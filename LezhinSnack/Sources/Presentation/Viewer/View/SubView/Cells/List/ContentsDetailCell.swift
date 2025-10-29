//
//  ContentsDetailCell.swift
//  LezhinSnack
//
//  Created by 신진우 on 4/30/25.
//


import UIKit
import Alamofire
import SnapKit

final class ContentsDetailCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 13)
        label.textColor = .white.withAlphaComponent(0.58)
        label.numberOfLines = 0                     // ← 여러 줄 허용
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var rockImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "ic_lock_fill")
        imageView.image = image
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cleanUp()
    }
    
    func cleanUp() {
        contentLabel.text = ""
    }
    
    func configure(content: String) {
        contentLabel.text = content
    }
    
    
    private func setupUI() {
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        
        let targetSize = CGSize(
            width: layoutAttributes.frame.width,
            height: UIView.layoutFittingCompressedSize.height
        )
        let autoSize = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        var newFrame = layoutAttributes.frame
        newFrame.size.height = ceil(autoSize.height)
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
    
}
