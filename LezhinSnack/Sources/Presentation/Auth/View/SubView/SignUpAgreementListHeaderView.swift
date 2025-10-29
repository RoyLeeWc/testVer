//
//  SignUpAgreementListHeaderView.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/18/25.
//

import UIKit

final class SignUpAgreementListHeaderView: UICollectionReusableView {
    
    
    let totalCheckBox = {
        let checkBox = LZSnackCheckBox()
        
        checkBox.checkedImage = UIImage(named: "ic_checked_white")?.withRenderingMode(.alwaysOriginal)
        checkBox.uncheckedImage = UIImage(named: "ic_checked")?.withRenderingMode(.alwaysOriginal)
        checkBox.partialImage = UIImage(named: "ic_checked")?.withRenderingMode(.alwaysOriginal)
        
        return checkBox
    }()
    
    var checkboxTapped: ((Bool) -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendardSemiBold(size: 14)
        label.textColor = .white
        label.text = "이용약관_전체동의_타이틀".localized
        return label
    }()
    
    var stateChanged: ((LZSnackCheckBox.CheckboxState) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        setupUI()
        setupGesture()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        backgroundColor = UIColor(.backgroundRaisedDefault)
        
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor(.borderSubtler).cgColor
        
        addSubview(totalCheckBox)
        
        totalCheckBox.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        totalCheckBox.addTarget(self,
                                action: #selector(checkboxChanged(_:)),
                                for: .valueChanged)
        
        totalCheckBox.setState(.unchecked)
        
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(totalCheckBox.snp.trailing).offset(8)
        }
    }
    
    // MARK: - Gesture
    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
        addGestureRecognizer(tap)
    }
    
    @objc private func headerTapped() {
        // 체크박스 상태 토글
        let newState: LZSnackCheckBox.CheckboxState =
        totalCheckBox.checkboxState == .checked ? .unchecked : .checked
        totalCheckBox.setState(newState)
    }
    
    // MARK: - Checkbox Value Changed
    @objc private func checkboxChanged(_ sender: LZSnackCheckBox) {
        stateChanged?(sender.checkboxState)
    }
    
}
