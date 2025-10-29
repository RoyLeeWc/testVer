//
//  FooterView.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/14/25.
//

import UIKit

final class MainBannerFooterView: UICollectionReusableView {
    
    private enum Mode { case `static`, dynamic }
    
    private var currentPageIndex: Int = -1
    private let threshold = 5
    private var mode: Mode?
    private var lastTotal: Int = 0
    /// 현재 섹션의 총 페이지 수를 알려줄 클로저 (VC에서 주입)
    var pageCountProvider: (() -> Int)?
    
    let dynamicPageControl: LZSnackDynamicPageControl = {
        let pageControl = LZSnackDynamicPageControl()
        //pc.translatesAutoresizingMaskIntoConstraints = false
        pageControl.dotColor = UIColor(.foregroundSubtler)
        pageControl.selectedColor = .white
        pageControl.pages = 0
        pageControl.selectedPage = 0
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()
    
    let staticPageControl: LZSnackStaticPageControl = {
        let pageControl = LZSnackStaticPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.pageIndicatorTintColor = UIColor(.foregroundSubtler)
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.numberOfPages = 0
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:)는 지원하지 않습니다.")
    }
    
    private func setupUI() {
        backgroundColor = .clear

        addSubview(staticPageControl)
        addSubview(dynamicPageControl)

        // 두 컨트롤 모두 동일한 레이아웃 제약
        [staticPageControl, dynamicPageControl].forEach { pc in
            pc.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            pc.backgroundColor = .clear
        }

        // 초기 상태: 일단 숨김 처리
        staticPageControl.isHidden = true
        dynamicPageControl.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currentPageIndex = -1
        mode = nil
        pageCountProvider = nil
        staticPageControl.isHidden = true
        dynamicPageControl.isHidden = true
        staticPageControl.numberOfPages = 0
        dynamicPageControl.pages = 0
        lastTotal = 0
    }
    
    /// 이제 index만 넘겨주면, 내부에서 provider로 총 페이지 수를 읽어 모드를 자동 결정
    func updateCurrentIndex(_ index: Int) {
        let total = max(0, pageCountProvider?() ?? 0)
        guard total > 0 else {
            staticPageControl.isHidden = true
            dynamicPageControl.isHidden = true
            lastTotal = 0
            return
        }
        
        let useStatic = (total <= threshold)
        let nextMode: Mode = useStatic ? .static : .dynamic
        let modeChanged = (mode != nextMode)
        mode = nextMode
        
        staticPageControl.isHidden = !useStatic
        dynamicPageControl.isHidden = useStatic
        
        // ✅ 총개수 바뀌었거나 모드가 바뀌었으면 항상 페이지 수 갱신
        if modeChanged || lastTotal != total {
            staticPageControl.numberOfPages = total
            dynamicPageControl.pages = total
            lastTotal = total
        }
        
        let clampedIndex = min(max(0, index), total - 1)
        guard clampedIndex != currentPageIndex else { return }
        currentPageIndex = clampedIndex
        
        if useStatic {
            staticPageControl.currentPage = clampedIndex
        } else {
            dynamicPageControl.selectedPage = clampedIndex
        }
    }
    
    
    func reset() {
        currentPageIndex = -1
    }
}
