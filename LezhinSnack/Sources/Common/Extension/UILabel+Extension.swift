//
//  UILabel.swift
//  Bomtoon_Renewal
//
//  Created by 신진우 on 1/26/25.
//

import UIKit

extension UILabel {
    func setColorForText(textToFind: String, withColor color: UIColor) {
        let fullText = self.text ?? ""
        let attributedString = NSMutableAttributedString(string: fullText)
        
        if let range = fullText.range(of: textToFind) {
            let nsRange = NSRange(range, in: fullText)
            let rangeToEnd = NSRange(location: nsRange.location, length: fullText.count - nsRange.location)
            attributedString.addAttribute(.foregroundColor, value: color, range: rangeToEnd)
        }
        
        self.attributedText = attributedString
    }
    
    func highlightNumbers(with color: UIColor = .systemGreen) {
        guard let text = self.text, !text.isEmpty else { return }
        
        // 1. NSMutableAttributedString 생성
        let attributed = NSMutableAttributedString(string: text)
        
        // 2. 정규식 패턴으로 숫자(한 자리 이상) 매치
        let pattern = "\\d+"
        let regex = try? NSRegularExpression(pattern: pattern)
        let matches = regex?.matches(in: text,
                                     range: NSRange(text.startIndex..., in: text)) ?? []
        
        // 3. 매치된 범위에만 색 속성 추가
        for match in matches {
            attributed.addAttribute(.foregroundColor,
                                    value: color,
                                    range: match.range)
        }
        
        // 4. UILabel에 적용
        self.attributedText = attributed
    }
    
    /// 줄 높이를 고정하고, 텍스트를 그 줄 안에서 수직 중앙정렬 상태로 그려줍니다.
    /// - Parameters:
    ///   - lineHeight: 원하는 줄 높이 (예: 30)
    ///   - alignment: 텍스트의 가로 정렬(기본은 label.textAlignment)
    func setLineHeight(_ lineHeight: CGFloat, alignment: NSTextAlignment? = nil) {
        guard let text = self.text,
              let font = self.font else { return }

        // 1) 폰트의 기본 lineHeight와 목표 lineHeight 차이 계산
        let originalLineHeight = font.lineHeight          // 예: 20pt
        let targetLineHeight = lineHeight                 // 예: 30pt
        let diff = targetLineHeight - originalLineHeight  // 30 − 20 = 10pt

        // 2) 중앙 정렬을 위해 OS가 주는 위쪽 여유(diff/2) 중 절반만 해제
        //    → baselineOffset를 (diff / 4)만큼 추가하면, 텍스트가 줄 박스 중앙으로 이동
        let baselineOffset = diff / 4                     // 10 / 4 = 2.5pt

        // 3) NSMutableParagraphStyle 생성 및 속성 설정
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = targetLineHeight
        paragraphStyle.maximumLineHeight = targetLineHeight
        paragraphStyle.alignment = alignment ?? self.textAlignment
        paragraphStyle.lineBreakMode = self.lineBreakMode
        paragraphStyle.lineBreakStrategy = self.lineBreakStrategy

        // 4) 속성 딕셔너리에 font, paragraphStyle, baselineOffset 포함
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle,
            .baselineOffset: baselineOffset
        ]

        // 5) AttributedString 생성 및 적용
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        self.attributedText = attributedString
    }
    
    func setText(_ text: String?, highlight keyword: String?, lineHeight: CGFloat) {
        let text = text ?? ""
        
        // 기존 attributedText를 완전히 제거하고 새로 시작
        self.attributedText = nil
        
        let attributed = NSMutableAttributedString(string: text)
        let fullRange = NSRange(location: 0, length: text.count)
        
        // 폰트 설정 (기존 폰트가 있다면)
        if let currentFont = self.font {
            attributed.addAttribute(.font, value: currentFont, range: fullRange)
        }
        
        // 기본 텍스트 색상
        attributed.addAttribute(.foregroundColor,
                                value: textColor ?? .white,
                                range: fullRange)
        
        // 라인 높이 설정
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = lineHeight
        paragraph.maximumLineHeight = lineHeight
        paragraph.alignment = textAlignment
        attributed.addAttribute(.paragraphStyle,
                                value: paragraph,
                                range: fullRange)
        
        // 하이라이트 키워드 적용
        if let kw = keyword, !kw.isEmpty {
            // 정확한 문자열 매칭을 원한다면 정규식 대신 range(of:) 사용도 고려
            let searchRange = text.startIndex..<text.endIndex
            var searchStartIndex = text.startIndex
            
            while searchStartIndex < text.endIndex,
                  let range = text.range(of: kw, options: .caseInsensitive, range: searchStartIndex..<text.endIndex) {
                
                let nsRange = NSRange(range, in: text)
                attributed.addAttribute(.foregroundColor,
                                        value: UIColor.foregroundBrand,
                                        range: nsRange)
                
                searchStartIndex = range.upperBound
            }
        }
        
        self.attributedText = attributed
    }
    
    /// 여러 줄(문단) 앞에 이미지 아이콘을 붙여서 표시하는 함수
    ///
    /// - **Parameters**:
    ///   - lines:      각 줄(문단)에 들어갈 문자열 배열
    ///   - iconName:   Assets 등에 등록된 이미지 이름
    ///   - iconSize:   아이콘 크기 (예: CGSize(width: 16, height: 16))
    ///   - baselineOffset: 아이콘과 텍스트의 수직 정렬을 맞추기 위한 기준선 오프셋 (예: -3)
    ///   - font:       텍스트 폰트 (예: UIFont.systemFont(ofSize: 14))
    ///   - textColor:  텍스트 색상 (예: UIColor.white)
    ///   - lineSpacing:     자동 줄 바꿈(line wrap) 이후 줄 간 간격 (예: 2)
    ///   - paragraphSpacing: 문단(줄)과 문단 사이 간격 (예: 8)
    func setIconBulletList(
        lines: [String],
        iconName: String,
        iconSize: CGSize = CGSize(width: 16, height: 16),
        baselineOffset: CGFloat = -3,
        font: UIFont = UIFont.systemFont(ofSize: 14),
        textColor: UIColor = .white,
        lineSpacing: CGFloat = 2,
        paragraphSpacing: CGFloat = 8
    ) {
        // 1) UILabel이 다중 줄을 지원하도록 설정
        self.numberOfLines = 0
        
        // 2) 전체 NSAttributedString을 담을 변수
        let fullAttributed = NSMutableAttributedString()

        // 3) 문단 스타일 정의
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.paragraphSpacing = paragraphSpacing
        
        // 아이콘 너비 + 8pt 패딩만큼 들여쓰기 설정
        let iconPadding: CGFloat = 8
        let totalIndent = iconSize.width + iconPadding
        
        // 두 번째 물리적 줄(자동 줄 바꿈된 줄)은 아이콘 + 패딩만큼 들여쓰기
        paragraphStyle.headIndent = totalIndent
        // 첫 번째 줄은 아이콘이 들어갈 영역이므로 들여쓰기 0
        paragraphStyle.firstLineHeadIndent = 0

        // 4) 각 줄마다 icon + 텍스트 조합해서 fullAttributed에 추가
        for (index, lineText) in lines.enumerated() {
            // 4-1) 아이콘 NSTextAttachment 생성
            let attachment = NSTextAttachment()
            if let image = UIImage(named: iconName) {
                attachment.image = image
                // 지정한 크기로 리사이즈
                attachment.bounds = CGRect(x: 0, y: baselineOffset, width: iconSize.width, height: iconSize.height)
            }
            let iconString = NSAttributedString(attachment: attachment)

            // 4-2) 8pt 패딩을 위한 공백 문자열 생성
            let paddingString = NSMutableAttributedString()
            
            // 8pt 너비의 투명한 NSTextAttachment 생성 (패딩 역할)
            let paddingAttachment = NSTextAttachment()
            paddingAttachment.bounds = CGRect(x: 0, y: 0, width: iconPadding, height: 1)
            // 투명한 1x1 이미지 생성
            let paddingImage = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { _ in
                UIColor.clear.setFill()
                UIRectFill(CGRect(x: 0, y: 0, width: 1, height: 1))
            }
            paddingAttachment.image = paddingImage
            paddingString.append(NSAttributedString(attachment: paddingAttachment))

            // 4-3) 텍스트 문자열 생성
            let textString = NSMutableAttributedString(string: lineText)

            // 4-4) 아이콘 + 패딩 + 텍스트 결합
            let combined = NSMutableAttributedString()
            combined.append(iconString)
            combined.append(paddingString)
            combined.append(textString)
            
            // 4-5) 문단별로 줄바꿈 추가 (마지막이 아닌 경우)
            if index < lines.count - 1 {
                combined.append(NSAttributedString(string: "\n"))
            }

            // 4-6) 전체에 추가
            fullAttributed.append(combined)
        }
        
        // 5) 전체 텍스트에 기본 속성과 문단 스타일 적용
        let fullRange = NSRange(location: 0, length: fullAttributed.length)
        fullAttributed.addAttributes([
            .font: font,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ], range: fullRange)

        // 6) UILabel에 할당
        self.attributedText = fullAttributed
    }
}
