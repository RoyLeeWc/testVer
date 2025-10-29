//
//  UIViewExtension.swift
//  Bomtoon_Renewal
//
//  Created by jinu0115 on 2/3/25.
//

import UIKit

extension UIView {
    
    static func loadFromNib() -> Self {
        return (Bundle(for: self).loadNibNamed(String(describing: self), owner: nil, options: nil)?.first as? Self)!
    }
    
    enum BorderPosition {
        case top, bottom, left, right
    }
    
    func roundCorners(cornerRadius: CGFloat, maskedCorners: CACornerMask = [.layerMinXMinYCorner,
                                                                            .layerMaxXMinYCorner,
                                                                            .layerMinXMaxYCorner,
                                                                            .layerMaxXMaxYCorner]) {
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = maskedCorners
    }
    
    func applyCornerRadius(updateFrame: Bool = false,cornerRadius: CGFloat = 16,color: UIColor = UIColor.clear) {
        if updateFrame, let superview = self.superview {
            self.frame = superview.bounds
        }
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = 1
        self.layer.borderColor = color.cgColor
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func makeShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.15   // 그림자 투명도
        self.layer.shadowRadius = 4
    }
    
    /// 특정 엣지에 보더를 추가합니다.
    /// - Parameters:
    ///   - position: 보더를 추가할 위치 (top, bottom, left, right)
    ///   - color: 보더 색상
    ///   - thickness: 보더 두께
    func addBorder(to edges: UIRectEdge, color: UIColor, thickness: CGFloat) {
        if edges.contains(.top) {
            let topBorder = CALayer()
            topBorder.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: thickness)
            topBorder.backgroundColor = color.cgColor
            layer.addSublayer(topBorder)
        }
        if edges.contains(.bottom) {
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0, y: frame.size.height - thickness, width: frame.size.width, height: thickness)
            bottomBorder.backgroundColor = color.cgColor
            layer.addSublayer(bottomBorder)
        }
        if edges.contains(.left) {
            let leftBorder = CALayer()
            leftBorder.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.size.height)
            leftBorder.backgroundColor = color.cgColor
            layer.addSublayer(leftBorder)
        }
        if edges.contains(.right) {
            let rightBorder = CALayer()
            rightBorder.frame = CGRect(x: frame.size.width - thickness, y: 0, width: thickness, height: frame.size.height)
            rightBorder.backgroundColor = color.cgColor
            layer.addSublayer(rightBorder)
        }
    }
    
    
    func makeSecure() {
        DispatchQueue.main.async {
            if !self.subviews.contains(where: { $0 is UITextField }) {
                let textField = UITextField()
                textField.isSecureTextEntry = true
                
                self.addSubview(textField)
                
//                // 캡쳐하려는 뷰의 레이어를 textField.layer 사이에 끼워넣기
                textField.layer.removeFromSuperlayer() // 이 코드가 없으면 run time error (layer 참조 관계에 cycle이 생성되므로)
                self.layer.superlayer?.insertSublayer(textField.layer, at: 0)
                textField.layer.sublayers?.last?.addSublayer(self.layer)
            }
        }
    }
    
    func deleteSecure() {
        // 여기에서 makeSecure 함수에서 생성한 UITextField에 접근하여 isSecureTextEntry 속성을 변경
        for subview in self.subviews {
            if let textField = subview as? UITextField {
                textField.removeFromSuperview()
            }
        }
    }
    
}
