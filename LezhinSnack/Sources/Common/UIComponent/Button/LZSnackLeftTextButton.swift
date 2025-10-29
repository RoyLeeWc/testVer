//
//  LZSnackLeftTextButton.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/20/25.
//

import UIKit

/// 텍스트는 왼쪽, 이미지(아이콘)는 오른쪽 끝에 고정 배치하는 커스텀 버튼
final class LZSnackLeftTextButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let imageView = imageView,
              let titleLabel = titleLabel else { return }

        // 1) 텍스트 레이블 왼쪽 여백(컨텐트 인셋) 기준으로 위치
        let leftInset = contentEdgeInsets.left
        titleLabel.frame.origin.x = leftInset

        // 2) 이미지 뷰는 버튼 전체 너비에서 오른쪽 인셋을 빼고 배치
        let rightInset = contentEdgeInsets.right
        let imageX = bounds.width - rightInset - imageView.frame.width
        imageView.frame.origin.x = imageX
    }
    
    override var isHighlighted: Bool {
        didSet {
            // 0.5는 어두워지는 정도, 원하면 수치 조절 가능
            titleLabel?.alpha = isHighlighted ? 0.5 : 1.0
            imageView?.alpha = isHighlighted ? 0.5 : 1.0
        }
    }
}
