//
//  UIPageControl+Extension.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/15/25.
//

import UIKit


final class LZSnackStaticPageControl: UIPageControl {
    override func layoutSubviews() {
        super.layoutSubviews()
        // dot들의 순서가 항상 일정하지 않을 수 있으므로, 전체 subviews 구조 확인 필요
        for (index, dot) in subviews.enumerated() {
            if index == 0 || index == subviews.count - 1 {
                dot.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            } else {
                dot.transform = .identity
            }
        }
    }
}

