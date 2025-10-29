//
//  UIImageExtension.swift
//  Bomtoon_Renewal
//
//  Created by 신진우 on 1/26/25.
//

import UIKit

extension UIImage {
    
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func mask(with color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        let rect = CGRect(origin: CGPoint.zero, size: size)
        
        color.setFill()
        self.draw(in: rect)
        
        context.setBlendMode(.sourceIn)
        context.fill(rect)
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resultImage
    }
    
    func withTransparentPadding(_ padding: CGFloat) -> UIImage {
        let newSize = CGSize(
            width: size.width + 2 * padding,
            height: size.height + 2 * padding
        )
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        let origin = CGPoint(x: padding, y: padding)
        draw(at: origin)
        let paddedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return paddedImage ?? self
    }
    
}
