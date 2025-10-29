//
//  LeftCheckToastView.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/17/25.
//

import UIKit
import SnapKit

final class LZSnackToastView: UIView {
    private let message: String
    private let showsIcon: Bool

    private lazy var iconImageView: UIImageView? = {
        guard showsIcon else { return nil }
        let imageView = UIImageView(image: UIImage(named: "ic_toast_check_color"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .pretendardRegular(size: 14)
        return label
    }()

    init(text: String, showsIcon: Bool = true) {
        self.message = text
        self.showsIcon = showsIcon
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:)는 지원하지 않습니다.")
    }

    private func setupUI() {
        backgroundColor = UIColor(.backgroundOverlay)
        layer.cornerRadius = 6

        if let iconView = iconImageView {
            addSubview(iconView)
            iconView.snp.makeConstraints { make in
                make.width.height.equalTo(20)
                make.leading.equalToSuperview().inset(16)
                make.centerY.equalToSuperview()
            }

            addSubview(label)
            label.text = message
            label.snp.makeConstraints { make in
                make.leading.equalTo(iconView.snp.trailing).offset(4)
                make.trailing.equalToSuperview().inset(16)
                make.centerY.equalToSuperview()
            }
        } else {
            addSubview(label)
            label.text = message
            label.snp.makeConstraints { make in
                make.leading.equalToSuperview().inset(16)
                make.trailing.equalToSuperview().inset(16)
                make.centerY.equalToSuperview()
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        let labelSize = label.intrinsicContentSize
        let totalWidth: CGFloat = showsIcon
            ? (16 /*left padding*/
               + 20 /*icon*/
               + 4 /*spacing*/
               + labelSize.width
               + 16 /*right padding*/)
            : (16 /*left padding*/
               + labelSize.width
               + 16 /*right padding*/)
        let contentHeight = showsIcon ? max(labelSize.height, 20) : labelSize.height
        let totalHeight: CGFloat = 16 /*top padding*/
            + contentHeight
            + 16 /*bottom padding*/
        return CGSize(width: totalWidth, height: totalHeight)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return intrinsicContentSize
    }
}

