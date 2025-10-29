//
//  LZSnackEditButton.swift
//  LezhinSnack
//
//  Created by 신진우 on 4/20/25.
//

import UIKit

/// 편집 버튼 컴포넌트
/// - `.system` 버튼 기반이며, 아이콘, 폰트, 색상, 간격 등을 Style로 커스터마이징할 수 있습니다.
public final class LZSnackEditButton: UIButton {
    // MARK: - Style Definition
    public struct Style {
        /// 편집 아이콘 이미지 (템플릿 모드 권장)
        public var icon: UIImage?
        /// 이미지와 텍스트 사이 간격
        public var spacing: CGFloat
        /// 텍스트 폰트
        public var font: UIFont
        /// 텍스트 색상
        public var textColor: UIColor
        /// 버튼 tintColor
        public var tintColor: UIColor

        public init(
            icon: UIImage? = UIImage(named: "ic_edit_white")?.withRenderingMode(.alwaysOriginal),
            spacing: CGFloat = 4,
            font: UIFont = UIFont.pretendardMedium(size: 13),
            textColor: UIColor = UIColor.white.withAlphaComponent(0.58),
            tintColor: UIColor = UIColor.white.withAlphaComponent(0.58)
        ) {
            self.icon = icon
            self.spacing = spacing
            self.font = font
            self.textColor = textColor
            self.tintColor = tintColor
        }

        /// 기본 스타일
        public static let `default` = Style()
    }

    // MARK: - Properties
    private var style: Style

    // MARK: - Initializers
    /// 스타일을 지정하여 초기화
    public init(style: Style = .default) {
        self.style = style
        super.init(frame: .zero)
        commonInit()
    }

    override public init(frame: CGRect) {
        self.style = .default
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder: NSCoder) {
        self.style = .default
        super.init(coder: coder)
        commonInit()
    }

    // MARK: - Setup
    private func commonInit() {
        setupAppearance()
    }

    private func setupAppearance() {
        // 아이콘
        if let iconImage = style.icon {
            setImage(iconImage, for: .normal)
        } else {
            setImage(nil, for: .normal)
        }
        tintColor = style.tintColor

        // 타이틀
        titleLabel?.font = style.font
        setTitleColor(style.textColor, for: .normal)

        // 이미지-텍스트 간격
        semanticContentAttribute = .forceLeftToRight
        imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: style.spacing)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: style.spacing, bottom: 0, right: 0)

        // 하이라이트 시 반투명 효과
        adjustsImageWhenHighlighted = true
    }

    // MARK: - Public API
    /// 버튼 타이틀 텍스트 설정
    public func setTitle(_ text: String) {
        setTitle(text, for: .normal)
    }

    /// 스타일을 동적으로 변경
    public func applyStyle(_ newStyle: Style) {
        self.style = newStyle
        setupAppearance()
    }
}

