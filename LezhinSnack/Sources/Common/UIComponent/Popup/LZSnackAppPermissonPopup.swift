//
//  LZSnackAppPermissionPopup.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/2/25.
//

import UIKit
import SnapKit

final class LZSnackAppPermissionPopup: BasePopupView {
    // MARK: - 크기 재정의
    private let popupWidthValue: CGFloat
    private let popupHeightValue: CGFloat

    override var popupWidth: CGFloat { popupWidthValue }
    override var popupHeight: CGFloat { popupHeightValue }

    // MARK: - UI 컴포넌트
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .pretendardBold(size: 18)
        label.textColor = .white
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 13)
        label.textColor = UIColor(.foregroundSubtler)
        label.numberOfLines = 0
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
    
    private let cameraIconView: UIImageView = {
        let image = UIImage(named: "ic_camera")?.resized(to: CGSize(width: 24,
                                                                   height: 24))
        let imageView = UIImageView(image: image)
        imageView.backgroundColor = UIColor(.backgroundRaisedHigh)
        imageView.contentMode = .center
        return imageView
    }()
    
    private let cameraTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardSemiBold(size: 14)
        label.textColor = UIColor(.white)
        label.numberOfLines = 0
        return label
    }()
    
    private let cameraDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 13)
        label.textColor = UIColor(.foregroundSubtler)
        label.numberOfLines = 0
        return label
    }()
    
    private let alarmIconView: UIImageView = {
        let image = UIImage(named: "ic_notifications")?.resized(to: CGSize(width: 24,
                                                                           height: 24))
        let imageView = UIImageView(image: image)
        imageView.backgroundColor = UIColor(.backgroundRaisedHigh)
        imageView.contentMode = .center
        return imageView
    }()
    
    private let alarmTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardSemiBold(size: 14)
        label.textColor = UIColor(.white)
        label.numberOfLines = 0
        return label
    }()
    
    private let alarmDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 13)
        label.textColor = UIColor(.foregroundSubtler)
        label.numberOfLines = 0
        return label
    }()

    // MARK: - 핸들러
    private var leftHandler: (() -> Void)?
    private var rightHandler: (() -> Void)?

    // MARK: - 초기화
    init(
        width: CGFloat = 300,
        height: CGFloat = 220,
        leftButtonTitle: String,
        leftHandler: @escaping () -> Void,
        rightButtonTitle: String,
        rightHandler: @escaping () -> Void,
    ) {
        self.popupWidthValue = width
        self.popupHeightValue = height
        super.init(frame: .zero)
        self.leftHandler = leftHandler
        self.rightHandler = rightHandler
        leftButton.setTitle(leftButtonTitle, for: .normal)
        rightButton.setTitle(rightButtonTitle, for: .normal)
    }

    convenience init(
        width: CGFloat = 300,
        height: CGFloat = 180,
        buttonTitle: String,
        handler: @escaping () -> Void,
    ) {
        self.init(
            width: width,
            height: height,
            leftButtonTitle: buttonTitle,
            leftHandler: handler,
            rightButtonTitle: buttonTitle,
            rightHandler: handler
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
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        contentView.addSubview(cameraIconView)
        cameraIconView.snp.makeConstraints { make in
            make.width.height.equalTo(54)
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
        }
        cameraIconView.roundCorners(cornerRadius: 27)
        
        
        contentView.addSubview(cameraTitleLabel)
        cameraTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(cameraIconView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(24)
            make.top.equalTo(cameraIconView.snp.top).offset(4)
        }
        
        contentView.addSubview(cameraDescriptionLabel)
        cameraDescriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(cameraIconView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(cameraTitleLabel.snp.bottom).offset(4)
        }
        
        
        contentView.addSubview(alarmIconView)
        alarmIconView.snp.makeConstraints { make in
            make.width.height.equalTo(54)
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(cameraIconView.snp.bottom).offset(16)
        }
        alarmIconView.roundCorners(cornerRadius: 27)
        
        contentView.addSubview(alarmTitleLabel)
        alarmTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(alarmIconView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(24)
            make.top.equalTo(alarmIconView.snp.top).offset(4)
        }
        
        contentView.addSubview(alarmDescriptionLabel)
        alarmDescriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(alarmIconView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(alarmTitleLabel.snp.bottom).offset(4)
        }
        
        contentView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(alarmIconView.snp.bottom).offset(20)
            
        }
        
        setText()
        
        leftButton.addTarget(self, action: #selector(didTapLeftButton), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(didTapRightButton), for: .touchUpInside)
    }
    
    
    func setText() {
        
        titleLabel.text = "앱 접근 권한 허용 안내"
        
        cameraTitleLabel.text = "사진/저장공간, 카메라 (선택)"
        cameraDescriptionLabel.text = "프로필 등록 시 사진 촬영 및 첨부"
        
        alarmTitleLabel.text = "알림 (선택)"
        alarmDescriptionLabel.text = "앱 내 각종 알림"
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 10                 // 첫 줄이 아닌 줄의 들여쓰기
        paragraphStyle.firstLineHeadIndent = 0         // 첫 줄 들여쓰기
        paragraphStyle.paragraphSpacing = 8            // 문단 간격
        
        let texts = [
          "Lezhin Snack은 정보통신망법 준수 및 차별화된 서비스를 제공하기 위해 서비스에 꼭 필요한 기능에 접근하고 있습니다.",
          "서비스 제공에 접근 권한이 필요한 경우에만 동의를 받고 있으며, 미동의 시에도 서비스 이용이 가능하나 일부 기능의 정상적인 이용이 어려울 수 있습니다."
        ]
        let attributed = NSMutableAttributedString()
        let attrs: [NSAttributedString.Key: Any] = [
          .font: descriptionLabel.font!,
          .foregroundColor: descriptionLabel.textColor!,
          .paragraphStyle: paragraphStyle
        ]
        for text in texts {
          attributed.append(NSAttributedString(string: "• \(text)\n", attributes: attrs))
        }
        descriptionLabel.attributedText = attributed
        
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
