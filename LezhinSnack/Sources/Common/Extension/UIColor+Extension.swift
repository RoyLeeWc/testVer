//
//  UIColorExtension.swift
//  Bomtoon_Renewal
//
//  Created by 신진우 on 3/3/25.
//

import UIKit


// 컬러셋만 추가하게 변경
public extension UIColor {
    enum CommonAssetsColorName: String {
        case whiteOpacity25
        case whiteOpacity35
        case whiteOpacity58
        case whiteOpacity70
        case darkGray333
        case blackOpacity52
        case blackOpacity72
        case baseBlack
        
        //브랜드
        case lezhinBrandRed
        case bomtoonBrandPink
        case snackBrandRed
        case brandRed
        
        //보더
        case borderSubtler
        case borderDefault
        case borderInput
        case borderBrandStronger
        
        //필
        case fillSubtler
        case fillSubtler100
        case fillDisabled
        case fillBrand
        case fillStaticBlack
        case fillInverse
        case fillTransparentPressed
        case fillGradientRed
        case fillGradientRedEdge
        case fillSubtlerPressed
        case fillInverseSubtle
        
        //백그라운드
        case backgroundOverlay
        case backgroundDefault
        case backgroundRaisedDefault
        case backgroundRaisedHigh
        case backgroundSelect
        
        //포그라운드
        case foregroundSubtler
        case foregroundDisabled
        case foregroundInverse
        case foregroundBrand
        
        case dimModal
    }
}


public extension UIColor {
    
    // 변경: named: 레이블을 붙여서 호출 시 enum 케이스임을 명확히
    convenience init(named assetsColorName: CommonAssetsColorName) {
        let nameString = assetsColorName.rawValue
        guard let color = UIColor(
            named: nameString,
            in: Bundle.main,
            compatibleWith: nil
        ) else {
            self.init(white: 0.5, alpha: 1.0)
            return
        }
        self.init(cgColor: color.cgColor)
    }
    
    /// RGB를 통한 색상 생성
    convenience init(red: UInt8, green: UInt8, blue: UInt8, alpha: Float = 1) {
        self.init(red: CGFloat(red)/255.0,
                  green: CGFloat(green)/255.0,
                  blue: CGFloat(blue)/255.0,
                  alpha: CGFloat(alpha))
    }

    convenience init(hexString: String) {
        var cString = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        // 유효한 6자리(또는 8자리 RGBA)를 가정
        if cString.count != 6 {
            // 기본 컬러 혹은 예외 처리
            self.init(white: 0.5, alpha: 1.0)
            return
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        let red = (rgbValue & 0xFF0000) >> 16
        let green = (rgbValue & 0x00FF00) >> 8
        let blue = (rgbValue & 0x0000FF)
        
        self.init(red: UInt8(red), green: UInt8(green), blue: UInt8(blue))
    }
    
    var hexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let rgb: Int = (Int)(red * 255) << 16
                     | (Int)(green * 255) << 8
                     | (Int)(blue * 255)
        
        return String(format: "#%06X", rgb)
    }
}
