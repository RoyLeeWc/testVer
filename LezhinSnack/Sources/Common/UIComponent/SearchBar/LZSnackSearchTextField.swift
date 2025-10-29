//
//  LZSnackSearchTextField.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/8/25.
//

import UIKit

protocol LZSnackSearchTextFieldDelegate: AnyObject {
    func searchTextFieldDidClear(_ textField: LZSnackSearchTextField)
}

final class LZSnackSearchTextField: UITextField {
    
    weak var lzsSearchBarDelegate: LZSnackSearchTextFieldDelegate?
    
    private let horizontalPadding: CGFloat = 12
    private lazy var customClearButton: UIButton = {
        let btn = UIButton(type: .custom)
        let icon = UIImage(named: "ic_search_bar_x")?.withRenderingMode(.alwaysOriginal)
        btn.setImage(icon, for: .normal)
        // 터치 영역 확장
        btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        clearButtonMode = .never
        rightView = customClearButton
        rightViewMode = .always
        
        customClearButton.addTarget(self, action: #selector(handleClear), for: .touchUpInside)
        addTarget(self, action: #selector(displayClearButtonIfNeeded), for: .editingChanged)
        
        rightView?.isHidden = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        clearButtonMode = .never
        rightView = customClearButton
        rightViewMode = .always
        
        customClearButton.addTarget(self, action: #selector(handleClear), for: .touchUpInside)
        addTarget(self, action: #selector(displayClearButtonIfNeeded), for: .editingChanged)
        
        rightView?.isHidden = true
    }

    @objc private func handleClear() {
        text = ""
        sendActions(for: .editingChanged)
        
        lzsSearchBarDelegate?.searchTextFieldDidClear(self)
    }
    
    @objc private func displayClearButtonIfNeeded() {
        self.rightView?.isHidden = (self.text?.isEmpty) ?? true
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let buttonSize: CGFloat = 44       // 터치 영역 포함 크기
        let xPosition = bounds.width - buttonSize   // 부모뷰 오른쪽 끝 기준
        let yPosition = (bounds.height - buttonSize) / 2
        return CGRect(
            x: xPosition,
            y: yPosition,
            width: buttonSize,
            height: buttonSize
        )
    }

    private func setupUI() {
        backgroundColor = .clear
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor(.borderInput).cgColor

        font = .systemFont(ofSize: 14, weight: .regular)
        textColor = .white

        placeholder = "장르, 키워드, 제목으로 검색"
        attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: [
                .foregroundColor: UIColor(.foregroundSubtler),
                .font: UIFont.pretendardRegular(size: 14)
            ]
        )
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(
            top: 0,
            left: horizontalPadding,
            bottom: 0,
            right: horizontalPadding + 44
        ))
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

//    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
//        var rect = super.clearButtonRect(forBounds: bounds)
//        rect.origin.x -= 6
//        return rect
//    }
}

extension LZSnackSearchTextField {
    /// 검색바 UI를 그대로 쓰되 닉네임 입력에 맞게 세팅
    func configureForNickname(placeholder: String = "닉네임을 입력하세요") {
        self.placeholder = placeholder
        self.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor(.foregroundSubtler),
                .font: UIFont.pretendardRegular(size: 14)
            ]
        )
        self.textContentType = .nickname
        self.keyboardType = .default
        self.returnKeyType = .done
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
        self.enablesReturnKeyAutomatically = true
    }
}
