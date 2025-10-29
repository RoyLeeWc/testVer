//
//  LZSnackGrabberView.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/5/25.
//

import UIKit
import SnapKit

final class LZSnackGrabberView: UIView {
    
    // MARK: - Subviews
    private let handleView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.15)
        view.layer.cornerRadius = 2
        return view
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGrabber()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGrabber()
    }
    
    // MARK: - Setup
    private func setupGrabber() {
        // 1) 배경을 투명으로 두거나 원하는 색 설정
        backgroundColor = .clear
        
        // 2) handleView를 추가
        addSubview(handleView)
        
        // 3) SnapKit 제약: 가운데 정렬, 32x4 크기
        handleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.centerX.equalToSuperview()
            make.width.equalTo(32)
            make.height.equalTo(4)
        }
    }
}
