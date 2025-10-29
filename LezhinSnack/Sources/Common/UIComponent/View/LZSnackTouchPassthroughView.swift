//
//  LZSnackTouchPassthroughView.swift
//  LezhinSnack
//
//  Created by 신진우 on 4/20/25.
//

import UIKit

class LZSnackTouchPassthroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for subview in subviews.reversed() {
            let converted = subview.convert(point, from: self)
            if let hit = subview.hitTest(converted, with: event) {
                return hit
            }
        }
        return nil
    }
}
