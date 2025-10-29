//
//  UIButton+Extension.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/27/25.
//
import UIKit

extension UIButton {
    func enablePressAnimation() {
        addTarget(self, action: #selector(pressDown), for: .touchDown)
        addTarget(self, action: #selector(pressUp),   for: [.touchUpInside, .touchCancel, .touchDragExit])
    }

    @objc private func pressDown() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }
    }

    @objc private func pressUp() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }
}
