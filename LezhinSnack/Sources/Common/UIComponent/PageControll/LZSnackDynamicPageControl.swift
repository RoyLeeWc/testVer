//
//  ScrollingPageControl.swift
//  LezhinSnack
//
//  Created by 신진우 on 4/18/25.
//

import UIKit

final class LZSnackDynamicPageControl: UIView {
    
    private func createViews() {
        dotViews = (0..<pages).map { _ in
            ScrollingPageControlDotView(frame: CGRect(origin: .zero, size: CGSize(width: dotSize, height: dotSize)))
        }
    }
    
    var selectedPage: Int = 0 {
        didSet {
            guard selectedPage != oldValue else { return }
            selectedPage = max(0, min(selectedPage, pages - 1))
            updateColors()
            
            let minimumThreshold = min(2, centerDots)
            if (minimumThreshold..<centerDots).contains(selectedPage - pageOffset) {
                centerOffset = selectedPage - pageOffset
            } else {
                pageOffset = selectedPage - centerOffset
            }
        }
    }

    var pages: Int = 0 {
        didSet {
            guard pages != oldValue else { return }
            // 1) 값 보정
            pages = max(0, pages)

            // 2) 초기화
            isFirstOffsetUpdate = true
            pageOffset = 0
            centerOffset = min(2, centerDots)

            // 3) 뷰 갱신
            UIView.performWithoutAnimation {
                invalidateIntrinsicContentSize()
                createViews()           // dotViews 다시 생성
                updateColors()          // 색상 초기화
                updatePositions()       // 위치 초기화
                layoutIfNeeded()
            }
        }
    }
    
    var maxDots = 7 {
        didSet {
            maxDots = max(0, maxDots)
            invalidateIntrinsicContentSize()
        }
    }
    
    var centerDots: Int {
        if pages <= maxDots { return pages }
        return maxDots - 2
    }
    
    var slideDuration: TimeInterval = 0.15
    
    private lazy var centerOffset = min(2, maxDots)
    
    private var isFirstOffsetUpdate = true

    private var pageOffset = 0 {
        didSet {
            pageOffset = max(0, min(pageOffset, pages - maxDots))
            let update = { self.updatePositions() }

            if isFirstOffsetUpdate {
                // 최초 한 번만
                UIView.performWithoutAnimation(update)
                isFirstOffsetUpdate = false
            } else {
                UIView.animate(
                    withDuration: slideDuration,
                    delay: 0.15,
                    options: [],
                    animations: update,
                    completion: nil
                )
            }
        }
    }
    
    private var dotViews: [UIView] = [] {
        didSet {
            oldValue.forEach { $0.removeFromSuperview() }
            dotViews.forEach(addSubview)
            updateColors()
            setNeedsLayout()
        }
    }
    
    var dotColor = UIColor(.black).withAlphaComponent(0.2) {
        didSet {
            updateColors()
        }
    }

    var selectedColor = UIColor(.white) {
        didSet {
            updateColors()
        }
    }
    
    var dotSize: CGFloat = 6 {
        didSet {
            dotSize = max(1, dotSize)
            dotViews.forEach { $0.frame = CGRect(origin: .zero, size: CGSize(width: dotSize, height: dotSize)) }
            invalidateIntrinsicContentSize()
        }
    }
    
    var spacing: CGFloat = 8 {
        didSet {
            spacing = max(1, spacing)
            invalidateIntrinsicContentSize()
        }
    }
    
    init() {
        super.init(frame: .zero)
        isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
    }
    
    private var lastSize = CGSize.zero
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.size != lastSize else { return }
        lastSize = bounds.size
        updatePositions()
    }
    
    private func updateColors() {
        dotViews.enumerated().forEach { page, dot in
            dot.tintColor = page == selectedPage ? selectedColor : dotColor
        }
    }
    
    func updatePositions() {
        let maxDots = min(self.maxDots, pages)
        let sidePages = (maxDots - centerDots) / 2
        
        let adjustedPageOffset = pageOffset + 1
        
        var horizontalOffset: CGFloat
        var bigDotsRange = pageOffset...(centerDots + pageOffset)
        
        // Scrollable한 경우
        if self.maxDots < self.pages {
            horizontalOffset = CGFloat(-adjustedPageOffset + sidePages) * (dotSize + spacing) + (bounds.width - intrinsicContentSize.width) / 2
            
            if 0 == pageOffset {
                bigDotsRange = (bigDotsRange.lowerBound)...(bigDotsRange.upperBound - 1)
            }
            
            if 0 < pageOffset {
                bigDotsRange = (bigDotsRange.lowerBound + 1)...(bigDotsRange.upperBound)
            }
            
            if pageOffset == (pages - maxDots) {
                bigDotsRange = (bigDotsRange.lowerBound + 1)...(bigDotsRange.upperBound + 1)
            }
        } else {
            horizontalOffset = (bounds.width - intrinsicContentSize.width) / 2
        }
        
        dotViews.enumerated().forEach { page, dot in
            let center = CGPoint(x: horizontalOffset + bounds.minX + dotSize / 2 + (dotSize + spacing) * CGFloat(page), y: bounds.midY)
            let scale: CGFloat = {
                if !(pageOffset..<maxDots + pageOffset).contains(page) {
                    return 0
                }
                
                if bigDotsRange.contains(page) {
                    return 1
                }
                
                return 0.75
            }()
            
            dot.frame = CGRect(origin: .zero, size: CGSize(width: dotSize * scale, height: dotSize * scale))
            dot.center = center
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let pages = min(maxDots, self.pages)
        let width = CGFloat(pages) * dotSize + CGFloat(pages - 1) * spacing
        let height = dotSize
        return CGSize(width: width, height: height)
    }
}

fileprivate class ScrollingPageControlDotView: UIView {
    override func tintColorDidChange() {
        self.backgroundColor = tintColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
    }
    
    override var frame: CGRect {
        didSet {
            updateCornerRadius()
        }
    }
    
    private func updateCornerRadius() {
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }
}
