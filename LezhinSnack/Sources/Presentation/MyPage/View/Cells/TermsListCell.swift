//
//  TermsListCell.swift
//  LezhinSnack
//
//  Created by lwc on 9/30/25.
//
import Foundation
import UIKit
import SnapKit


final class TermsListCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: TermsListCell.self)
    private let termsContainerView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 16)
        label.textColor = .white
        return label
    }()
    
    private let chevron: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "ic_chevron_right_white"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.addSubview(titleLabel)
        contentView.addSubview(chevron)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(chevron.snp.leading).offset(-8)
        }
        chevron.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(_ item: TermsItem) {
        titleLabel.text = item.title
    }
}
