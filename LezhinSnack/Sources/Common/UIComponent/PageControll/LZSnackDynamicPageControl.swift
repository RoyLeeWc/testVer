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
            // 1) 클램프
            let clamped = max(0, min(selectedPage, pages - 1))
            if clamped != selectedPage {
                selectedPage = clamped
                return
            }
            guard selectedPage != oldValue else { return }
            // 2) 색상 즉시 반영
            updateColors()
            
            // 3) pageOffset 변화 여부 체크
            let oldOffset = pageOffset
            // 4) 오프셋/센터 보정 (네 코드 그대로)
            let minimumThreshold = min(2, centerDots)
            if (minimumThreshold..<centerDots).contains(selectedPage - pageOffset) {
                centerOffset = selectedPage - pageOffset
            } else {
                pageOffset = selectedPage - centerOffset  // ← 변하면 didSet에서 updatePositions() 호출됨
            }
            // 5) ★ 핵심: pageOffset이 안 바뀌었다면 여기서 위치/크기 재계산 실행
            if pageOffset == oldOffset {
                UIView.performWithoutAnimation { self.updatePositions() }
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
    
    var maxDots = 6 {
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
        guard pages > 0 else { return }
        
        let visibleMax   = min(maxDots, pages)        // 한 번에 보일 점 수(최대 6)
        let dynamicMode  = pages >= visibleMax        // ≥6면 동적 모드
        let exactlyMax   = (pages == visibleMax)      // 정확히 6개
        
        // 현재 보이는 창(window)
        let windowStart = min(max(0, pageOffset), max(0, pages - visibleMax))
        let windowEnd   = min(pages - 1, windowStart + visibleMax - 1)
        
        // 가운데 정렬
        let visibleCount = windowEnd - windowStart + 1
        let visibleWidth = CGFloat(visibleCount) * dotSize + CGFloat(visibleCount - 1) * spacing
        let offsetX = (bounds.width - visibleWidth) / 2
        
        let smallScale: CGFloat = 0.75
        
        
        let leftSmall: Bool
        let rightSmall: Bool
        if !dynamicMode {
            leftSmall = false
            rightSmall = false
        } else if exactlyMax {
            let i = max(0, min(pages - 1, selectedPage))
            switch i {
            case 0...2:
                leftSmall  = false
                rightSmall = true
            case 3...4:
                leftSmall  = true
                rightSmall = true
            default: // i >= Last
                leftSmall  = true
                rightSmall = false
            }
        } else {
            leftSmall  = (windowStart > 0)
            rightSmall = (windowEnd   < pages - 1)
        }
        
        // === 점 배치/스케일 ===
        for (page, dot) in dotViews.enumerated() {
            let inWindow = (windowStart...windowEnd).contains(page)
            let idxInWindow = CGFloat(page - windowStart)
            let center = CGPoint(
                x: offsetX + dotSize / 2 + (dotSize + spacing) * idxInWindow,
                y: bounds.midY
            )
            
            // 선택된 점은 항상 크게 (우선순위 최상)
            let isActive = (page == selectedPage)
            
            let scale: CGFloat
            if !inWindow {
                scale = 0
            } else if isActive {
                scale = 1.0
            } else if (page == windowStart && leftSmall) || (page == windowEnd && rightSmall) {
                scale = smallScale
            } else {
                scale = 1.0
            }
            
            dot.frame = CGRect(origin: .zero,
                               size: CGSize(width: dotSize * scale, height: dotSize * scale))
            dot.center = center
        }
        
        updateColors() // 색상은 selectedPage 기준 유지
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
