//
//  PushCustomNavigationBar.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/11/25.
//


import UIKit
import SnapKit

final class ChildNavigationBar: UIView {
    
    weak var delegate: ChildNavigationBarDelegate?
    
    let backButton: UIButton = {
        let button = UIButton(type: .system)
        
        let backImage = UIImage(named: "ic_chevron_left_white")?.withRenderingMode(.alwaysOriginal)
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
        
        addSubview(backButton)
        addSubview(titleLabel)
        
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(backButton.snp.trailing).offset(8)
        }
        
        titleLabel.isUserInteractionEnabled = true
        let titleTap = UITapGestureRecognizer(target: self, action: #selector(backButtonTapped))
        titleLabel.addGestureRecognizer(titleTap)
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    @objc private func backButtonTapped() {
        delegate?.childNavigationBarDidTapBack(self)
    }
}
