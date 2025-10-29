//
//  RecommendFooterView.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/14/25.
//

import UIKit

final class RecommendFooterView: UICollectionReusableView {
    
    private var currentPageIndex: Int = -1
    private let threshold = 5
    
    private let keywordLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(.white)
        label.textAlignment = .center
        return label
    }()
    
    private let dynamicPageControl: LZSnackDynamicPageControl = {
        let pageControl = LZSnackDynamicPageControl()
        //pc.translatesAutoresizingMaskIntoConstraints = false
        pageControl.dotColor = UIColor(.foregroundSubtler)
        pageControl.selectedColor = .white
        pageControl.pages = 6
        pageControl.selectedPage = 0
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()
    
    private let staticPageControl: LZSnackStaticPageControl = {
        let pageControl = LZSnackStaticPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.pageIndicatorTintColor = UIColor(.foregroundSubtler)
        pageControl.currentPageIndicatorTintColor = .white
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

        addSubview(keywordLabel)
        addSubview(staticPageControl)
        addSubview(dynamicPageControl)

        keywordLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(22)
        }
        // 두 컨트롤 모두 동일한 레이아웃 제약
        [staticPageControl, dynamicPageControl].forEach { pc in
            pc.snp.makeConstraints { make in
                make.top.equalTo(keywordLabel.snp.bottom).offset(32)
                make.leading.trailing.bottom.equalToSuperview()
            }
            pc.backgroundColor = .clear
        }

        // 초기 상태: 일단 숨김 처리
        staticPageControl.isHidden = true
        dynamicPageControl.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func updateCurrentIndex(_ index: Int, totalPages: Int = 5) {
        guard index != currentPageIndex else { return }
        currentPageIndex = index

        if totalPages <= threshold {
            // 정적 페이저 사용
            staticPageControl.isHidden = false
            dynamicPageControl.isHidden = true

            staticPageControl.numberOfPages = totalPages
            staticPageControl.currentPage = index
        } else {
            // 스크롤 페이저 사용
            staticPageControl.isHidden = true
            dynamicPageControl.isHidden = false

            dynamicPageControl.pages = totalPages
            dynamicPageControl.selectedPage = index
        }
    }
    
    
    func updateCurrentKeyword(keywords: [String]) {
        
        let attributedText = NSMutableAttributedString()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.pretendardMedium(size: 16),
            .foregroundColor: UIColor.white
        ]
        let keywordsString = keywords.joined(separator: " · ")
        
        attributedText.append(NSAttributedString(string: keywordsString, attributes: attributes))
        
        keywordLabel.attributedText = attributedText
    }
    
    
    func reset() {
        currentPageIndex = -1
    }
}
