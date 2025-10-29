//
//  LZSnackPaddingLabel.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/20/25.
//


import UIKit

/// 텍스트 주변에 여백을 줄 수 있는 UILabel 서브클래스
final class LZSnackPaddingLabel: UILabel {
    /// 원하는 여백 설정 (default는 좌우 4pt)
    var textInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    override var intrinsicContentSize: CGSize {
        let base = super.intrinsicContentSize
        return CGSize(
            width: base.width + textInsets.left + textInsets.right,
            height: base.height + textInsets.top + textInsets.bottom
        )
    }
}
