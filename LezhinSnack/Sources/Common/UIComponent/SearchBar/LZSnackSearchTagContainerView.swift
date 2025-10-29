//
//  LZSnackSearchTagContainer.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/8/25.
//

import UIKit
import TTGTags

final class LZSnackSearchTagContainerView: UIView {

    // MARK: – 프로퍼티
    let tagCollectionView = TTGTextTagCollectionView()

    // MARK: – 초기화
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayoutAndStyle()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureLayoutAndStyle()
    }

    // MARK: – 레이아웃 및 스타일 설정
    private func configureLayoutAndStyle() {
        addSubview(tagCollectionView)
        tagCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: – 태그 적용
    /// 외부에서 호출하여 태그 텍스트 배열을 설정합니다.
    func applySearchTagTitles(_ tagTitles: [String]) {
        
        tagCollectionView.alignment = .left
        tagCollectionView.horizontalSpacing = 4
        tagCollectionView.verticalSpacing   = 4
        tagCollectionView.contentInset      = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        tagCollectionView.scrollDirection   = .vertical
        tagCollectionView.scrollView.showsHorizontalScrollIndicator = false
        tagCollectionView.scrollView.bounces = false
        
        tagCollectionView.removeAllTags()
        
        let tagStyle = TTGTextTagStyle()
        tagStyle.backgroundColor = UIColor(.backgroundDefault)
        tagStyle.borderColor = UIColor(.borderDefault)
        tagStyle.extraSpace      = CGSize(width: 20, height: 10)
        tagStyle.exactHeight     = 30
        tagStyle.cornerRadius    = 15

        tagTitles.forEach { title in
            
            let content = TTGTextTagStringContent(
                text: title,
                textFont: .pretendardSemiBold(size: 13),
                textColor: UIColor(.white)
            )
            
            let tag     = TTGTextTag(content: content, style: tagStyle)
            tagCollectionView.addTag(tag)
        }

        tagCollectionView.reload()
    }
    
    func applySearchTagTitlesWithX(_ tagTitles: [String]) {
        
        tagCollectionView.alignment = .left
        tagCollectionView.horizontalSpacing = 8
        tagCollectionView.verticalSpacing   = 4
        tagCollectionView.contentInset      = UIEdgeInsets(top: 3, left: 1, bottom: 3, right: 1)
        tagCollectionView.scrollDirection   = .horizontal
        tagCollectionView.scrollView.showsHorizontalScrollIndicator = false
        tagCollectionView.scrollView.bounces = false
        tagCollectionView.numberOfLines = 1
        
        tagCollectionView.removeAllTags()
        
        let tagStyle = TTGTextTagStyle()
        tagStyle.backgroundColor = UIColor(.backgroundDefault)
        tagStyle.borderColor     = UIColor(.borderDefault)
        tagStyle.extraSpace      = CGSize(width: 20, height: 10)
        tagStyle.cornerRadius    = 15
        
        tagTitles.forEach { title in
            // 공통 폰트
            let font = UIFont.pretendardSemiBold(size: 13)

            // 1) 기본 타이틀 어트리뷰티드 (흰색)
            let attributed = NSMutableAttributedString(
                string: title,
                attributes: [
                    .font: font,
                    .foregroundColor: UIColor(.white)
                ]
            )
            // 2) " X" 어트리뷰티드 추가 (회색)
            let xAttr = NSAttributedString(
                string: " X",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 13),
                    .foregroundColor: UIColor(.foregroundSubtler)
                ]
            )
            attributed.append(xAttr)

            // 3) TTG 태그로 감싸기
            let content = TTGTextTagAttributedStringContent(attributedText: attributed)
            let tag = TTGTextTag(content: content, style: tagStyle)
            tagCollectionView.addTag(tag)
        }

        tagCollectionView.reload()
    }
    
    
    func applyItemTagTitles(_ tagTitles: [String], highlight keyword: String?) {
        // 1) 기본 설정
        tagCollectionView.alignment          = .left
        tagCollectionView.horizontalSpacing = 4
        tagCollectionView.contentInset      = .zero
        tagCollectionView.scrollDirection   = .horizontal
        tagCollectionView.scrollView.showsHorizontalScrollIndicator = false
        tagCollectionView.scrollView.bounces = false
        tagCollectionView.removeAllTags()

        // 2) 스타일 정의 (여기서 extraSpace로 패딩 유지)
        let tagStyle = TTGTextTagStyle()
        tagStyle.backgroundColor = UIColor(.fillSubtlerPressed)
        tagStyle.borderColor     = .clear
        tagStyle.cornerRadius    = 4
        tagStyle.extraSpace      = CGSize(width: 8, height: 4)

        tagTitles.forEach { title in
            let fullRange = NSRange(location: 0, length: (title as NSString).length)
            let attributed = NSMutableAttributedString(string: title)
            attributed.addAttribute(.font,
                                    value: UIFont.pretendardMedium(size: 12),
                                    range: fullRange)
            attributed.addAttribute(.foregroundColor,
                                    value: UIColor(.foregroundSubtler),
                                    range: fullRange)

            if let kw = keyword, !kw.isEmpty {
                let pattern = NSRegularExpression.escapedPattern(for: kw)
                if let re = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                    re.matches(in: title, options: [], range: fullRange).forEach { m in
                        attributed.addAttribute(.foregroundColor,
                                                value: UIColor.red,
                                                range: m.range)
                    }
                }
            }

            // 3) attributedText만 넘기고, padding(extraSpace)은 style에서 처리
            let content = TTGTextTagAttributedStringContent(attributedText: attributed)
            let tag     = TTGTextTag(content: content, style: tagStyle)
            tagCollectionView.addTag(tag)
        }

        tagCollectionView.reload()
    }
    
    @objc private func tagViewTapped(_ gesture: UITapGestureRecognizer) {
        printX("❌ 태그 \(index) 삭제")
    }
    
}
