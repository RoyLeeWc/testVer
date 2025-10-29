//
//  ChildRightCloseNavigationBar.swift
//  LezhinSnack
//
//  Created by 신진우 on 5/22/25.
//

import UIKit
import SnapKit

final class ChildRightCloseNavigationBar: UIView {
    
    weak var delegate: ChildRightCloseNavigationBarDelegate?
    
    let rightCloseButton: UIButton = {
        let button = UIButton(type: .system)
        
        let backImage = UIImage(named: "ic_close")?.withRenderingMode(.alwaysOriginal)
        button.setImage(backImage, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "타이틀"
        label.font = .pretendardBold(size: 20)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor(.backgroundDefault)
        
        addSubview(rightCloseButton)
        addSubview(titleLabel)
        
        rightCloseButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }
        
        titleLabel.isUserInteractionEnabled = true
        let titleTap = UITapGestureRecognizer(target: self, action: #selector(rightCloseButtonTapped))
        titleLabel.addGestureRecognizer(titleTap)
        
        rightCloseButton.addTarget(self, action: #selector(rightCloseButtonTapped), for: .touchUpInside)
    }
    
    @objc private func rightCloseButtonTapped() {
        delegate?.childNavigationBarDidTapClose(self)
    }
}
