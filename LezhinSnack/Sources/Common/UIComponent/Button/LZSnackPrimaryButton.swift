//
//  LZSnackPrimaryButton.swift
//  LezhinSnack
//
//  Created by lwc on 10/20/25.
//

import UIKit

/// 앱 공통 프라이머리 버튼
/// - 고정: 배경색 = .fillBrand, tint = .white, cornerRadius = 6
/// - 가변: 타이틀, 폰트 사이즈(기본 16)
final class LZSnackPrimaryButton: UIButton {

    /// 지정 생성자
    /// - Parameters:
    ///   - title: 버튼 타이틀(외부에서 localized 적용)
    ///   - fontSize: Pretendard SemiBold 사이즈 (기본 16)
    init(title: String, fontSize: CGFloat = 16) {
        super.init(frame: .zero)
        commonInit()
        apply(title: title, fontSize: fontSize)
    }

    /// 빈 생성자(타이틀/사이즈 나중에 적용하고 싶을 때)
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    /// 타이틀/폰트 사이즈 변경용
    func apply(title: String, fontSize: CGFloat = 16) {
        setTitle(title, for: .normal)
        titleLabel?.font = .pretendardSemiBold(size: fontSize)
    }

    // MARK: - Private
    private func commonInit() {
        // 고정 스타일
        backgroundColor = UIColor(.fillBrand)
        tintColor = UIColor(.white)
        setTitleColor(UIColor(.white), for: .normal) // system 타입 안정화를 위해 명시
        layer.cornerRadius = 6
        clipsToBounds = true

        // 터치 피드백(가벼운 디밍)
        addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(touchUp),   for: [.touchCancel, .touchDragExit, .touchUpInside, .touchUpOutside])
    }

    @objc private func touchDown() { alpha = 0.85 }
    @objc private func touchUp()   { UIView.animate(withDuration: 0.12) { self.alpha = 1 } }

    // 비활성화 시 살짝 흐리게
    override var isEnabled: Bool {
        didSet { alpha = isEnabled ? 1.0 : 0.5 }
    }
}
