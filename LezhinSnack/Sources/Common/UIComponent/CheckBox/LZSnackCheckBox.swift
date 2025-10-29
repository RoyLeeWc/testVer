//
//  LZSnackCheckBox.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/18/25.
//

import UIKit

@IBDesignable
class LZSnackCheckBox: UIControl {
    // MARK: - State 열거형
    enum CheckboxState {
        case unchecked, checked, partial
    }

    // MARK: - Public 프로퍼티
    /// 현재 체크박스 상태 (UIControl.state와 이름 충돌 방지)
    @Published private(set) var checkboxState: CheckboxState = .unchecked {
        didSet { updateAppearance() }
    }

    /// 사용자 지정 이미지 (설정하지 않으면 기본 이미지 사용)
    @IBInspectable var uncheckedImage: UIImage? { didSet { updateAppearance() } }
    @IBInspectable var checkedImage: UIImage?   { didSet { updateAppearance() } }
    @IBInspectable var partialImage: UIImage?   { didSet { updateAppearance() } }

    // MARK: - 기본 이미지
    private let defaultUnchecked = UIImage(named: "checkboxUnselected")
    private let defaultChecked   = UIImage(named: "checkboxSelected")
    private let defaultPartial   = UIImage(named: "checkboxPartial")

    // MARK: - UI
    private let imageView = UIImageView()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        // 1) 이미지뷰 세팅
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        // 2) 탭 이벤트 연결
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)

        // 3) 초기 외형 반영
        updateAppearance()
    }

    // MARK: - 토글 로직
    @objc private func handleTap() {
        switch checkboxState {
        case .checked:
            checkboxState = .unchecked
        default:
            checkboxState = .checked
        }
        sendActions(for: .valueChanged)
    }

    // MARK: - 외형 업데이트
    private func updateAppearance() {
        let img: UIImage?
        switch checkboxState {
        case .unchecked:
            img = uncheckedImage ?? defaultUnchecked
        case .checked:
            img = checkedImage   ?? defaultChecked
        case .partial:
            img = partialImage   ?? defaultPartial
        }
        imageView.image = img
    }

    // MARK: - 외부에서 상태 설정 API
    /// partial 상태로 강제 전환
    func setPartial() {
        checkboxState = .partial
        sendActions(for: .valueChanged)
    }
    /// 원하는 상태로 설정
    func setState(_ newState: CheckboxState) {
        checkboxState = newState
        sendActions(for: .valueChanged)
    }
}
