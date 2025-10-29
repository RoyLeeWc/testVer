//
//  UISliderExtension.swift
//  Bomtoon_Renewal
//
//  Created by 신진우 on 1/29/25.
//

import UIKit

final class LZSnackTapSlider: UISlider {
    /// thumb 터치 영역 확장 크기 (전체 너비 기준)
    @IBInspectable var thumbTouchAreaExpansion: CGFloat = 20
    
//    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
//        // 터치된 지점
//        let touchPoint = touch.location(in: self)
//        
//        // 슬라이더 트랙의 위치와 크기
//        let trackRect = self.trackRect(forBounds: self.bounds)
//        
//        // thumb의 이미지가 있는 경우를 고려해 width를 구함 (없다면 0)
//        let thumbWidth = self.currentThumbImage?.size.width ?? 0
//        
//        // 실제로 값이 이동할 수 있는 트랙의 사용 가능 범위
//        let availableWidth = trackRect.width - thumbWidth
//        
//        // 최소값~최대값 사이의 비율을 계산해 새로운 value를 구함
//        let newValue = self.minimumValue
//            + Float((touchPoint.x - trackRect.origin.x - thumbWidth/2)
//                    / availableWidth)
//            * (self.maximumValue - self.minimumValue)
//        
//        // 계산된 값을 슬라이더의 value로 설정
//        self.setValue(newValue, animated: true)
//        
//        // 기존 드래그 동작을 그대로 처리할지 여부를 결정
//        return super.beginTracking(touch, with: event)
//    }
    
    @IBInspectable var trackHeight: CGFloat = 3

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        // Use properly calculated rect
        var newRect = super.trackRect(forBounds: bounds)
        newRect.size.height = trackHeight
        return newRect
    }
    
//    override func thumbRect(forBounds bounds: CGRect,
//                            trackRect rect: CGRect,
//                            value: Float) -> CGRect {
//        // 원본 thumb 위치
//        let original = super.thumbRect(forBounds: bounds,
//                                       trackRect: rect,
//                                       value: value)
//        // insetBy에 음수 값을 주면 영역이 확장됨
//        return original.insetBy(dx: -thumbTouchAreaExpansion/2,
//                                dy: -thumbTouchAreaExpansion/2)
//    }
    
}
