//
//  RecentSearchTagCell.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/26/25.
//

import UIKit

protocol TagCellDelegate: AnyObject {
    /// 닫기 버튼이 탭됐을 때 호출
    func tagCellDidTapClose(keyword: String?)
    func tagCellDidTapSearch(keyword: String?)
}

final class RecentSearchTagCell: UICollectionViewCell {
    
    weak var delegate: TagCellDelegate?
    
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor(.backgroundDefault)
        contentView.layer.cornerRadius = 15
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor(.borderDefault).cgColor
        
        titleLabel.font = .pretendardSemiBold(size: 13)
        titleLabel.textColor = .white
        
        let closeImage = UIImage(named: "ic_close_gray")?.withRenderingMode(.alwaysOriginal)
        closeButton.setImage(closeImage, for: .normal)
        closeButton.contentMode = .scaleAspectFit
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(closeButton)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        closeButton.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(2)
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        
        titleLabel.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapTitle))
        titleLabel.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func didTapTitle() {
        delegate?.tagCellDidTapSearch(keyword: titleLabel.text)
    }
    
    @objc private func didTapClose() {
        delegate?.tagCellDidTapClose(keyword: titleLabel.text)
    }
    
    func configure(text: String) {
        titleLabel.text = text
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
