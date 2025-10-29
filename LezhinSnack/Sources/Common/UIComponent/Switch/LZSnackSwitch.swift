//
//  LZSnackSwitch.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/20/25.
//

import UIKit

final class LZSnackSwitch: UIControl {
    
    // MARK: - Public

    /// 터치하면 자동으로 on/off를 업데이트할지 여부
    public var isToggleOnTapEnabled: Bool = true
    
    private(set) var isOn: Bool = false {
        didSet { updateAppearance(animated: true) }
    }
    func setOn(_ on: Bool, animated: Bool) {
        isOn = on
        updateAppearance(animated: animated)
    }
    
    // MARK: - Subviews
    
    private let trackView = UIView()
    private let thumbView = UIView()
    
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
        trackView.backgroundColor = .gray
        addSubview(trackView)
        
        thumbView.backgroundColor = .white
        addSubview(thumbView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapSwitch))
        addGestureRecognizer(tap)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 40, height: 22)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let margin: CGFloat = 1
        let thumbSize = bounds.height - margin * 2
        trackView.frame = bounds
        trackView.layer.cornerRadius = bounds.height / 2
        
        let thumbX = isOn
            ? bounds.width - margin - thumbSize
            : margin
        thumbView.frame = CGRect(x: thumbX, y: margin, width: thumbSize, height: thumbSize)
        thumbView.layer.cornerRadius = thumbSize / 2
    }
    
    // MARK: - Action
    
    @objc private func didTapSwitch() {
        if isToggleOnTapEnabled {
            isOn.toggle()
            sendActions(for: .valueChanged)
        } else {
            // 토글 없이 단순 터치 이벤트만 전달
            sendActions(for: .touchUpInside)
        }
    }
    
    // MARK: - Appearance
    
    private func updateAppearance(animated: Bool) {
        let trackColor = isOn ? UIColor.red : UIColor.gray
        let apply = {
            self.trackView.backgroundColor = trackColor
            self.layoutSubviews()
        }
        if animated {
            UIView.animate(withDuration: 0.25, animations: apply)
        } else {
            apply()
        }
    }
}
