//
//  LZSnackAlertPopupView.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/21/25.
//

import UIKit

final class LZSnackAlertPopupView: BasePopupView {
    // MARK: - 크기 재정의
    private let popupWidthValue: CGFloat
    private let popupHeightValue: CGFloat

    override var popupWidth: CGFloat { popupWidthValue }
    override var popupHeight: CGFloat { popupHeightValue }

    // MARK: - UI 컴포넌트
    private let closeButton: UIButton = {
        let button = UIButton(type: .custom)
        let closeImage = UIImage(named: "ic_close")?.resized(to: CGSize(width: 24, height: 24))
        button.setImage(closeImage, for: .normal)
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .pretendardBold(size: 18)
        label.textColor = .white
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .pretendardRegular(size: 14)
        label.textColor = .white
        return label
    }()

    private let leftButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .pretendardSemiBold(size: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(.borderDefault).cgColor
        button.layer.cornerRadius = 6
        return button
    }()

    private let rightButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .pretendardSemiBold(size: 16)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 6
        return button
    }()

    // MARK: - 핸들러
    private var leftHandler: (() -> Void)?
    private var rightHandler: (() -> Void)?
    private var closeHandler: (() -> Void)?
    private let showsCloseButton: Bool

    // MARK: - 초기화
    init(
        width: CGFloat = 300,
        height: CGFloat = 220,
        title: String,
        message: String,
        leftButtonTitle: String,
        leftHandler: @escaping () -> Void,
        rightButtonTitle: String,
        rightHandler: @escaping () -> Void,
        showsCloseButton: Bool = false,
        closeHandler: (() -> Void)? = nil
    ) {
        self.popupWidthValue = width
        self.popupHeightValue = height
        self.showsCloseButton = showsCloseButton
        self.closeHandler = closeHandler
        super.init(frame: .zero)
        titleLabel.text = title
        messageLabel.text = message
        self.leftHandler = leftHandler
        self.rightHandler = rightHandler
        leftButton.setTitle(leftButtonTitle, for: .normal)
        rightButton.setTitle(rightButtonTitle, for: .normal)
        
        titleLabel.setLineHeight(24, alignment: .center)
        messageLabel.setLineHeight(23, alignment: .center)
    }

    convenience init(
        width: CGFloat = 300,
        height: CGFloat = 180,
        title: String,
        message: String,
        buttonTitle: String,
        handler: @escaping () -> Void,
        showsCloseButton: Bool = false,
        closeHandler: (() -> Void)? = nil
    ) {
        self.init(
            width: width,
            height: height,
            title: title,
            message: message,
            leftButtonTitle: buttonTitle,
            leftHandler: handler,
            rightButtonTitle: buttonTitle,
            rightHandler: handler,
            showsCloseButton: showsCloseButton,
            closeHandler: closeHandler
        )
        leftButton.isHidden = true
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 레이아웃
    override func setupContentView() {
        contentView.backgroundColor = UIColor(.backgroundOverlay)
        contentView.layer.cornerRadius = 12

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        contentView.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        let buttonStack = UIStackView(arrangedSubviews: [leftButton, rightButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 8
        buttonStack.distribution = .fillEqually
        contentView.addSubview(buttonStack)
        buttonStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }
        
        if showsCloseButton {
            contentView.addSubview(closeButton)
            closeButton.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(4)
                make.trailing.equalToSuperview().offset(-4)
                make.width.height.equalTo(40)
            }
            closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        }

        leftButton.addTarget(self, action: #selector(didTapLeftButton), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(didTapRightButton), for: .touchUpInside)
    }

    @objc private func didTapCloseButton() {
        dismissPopup()
        closeHandler?()
    }

    @objc private func didTapLeftButton() {
        dismissPopup()
        leftHandler?()
    }

    @objc private func didTapRightButton() {
        dismissPopup()
        rightHandler?()
    }
}
