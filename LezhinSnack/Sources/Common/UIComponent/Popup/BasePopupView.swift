//
//  BasePopupView.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/9/25.
//

import UIKit
import SnapKit

class BasePopupView: UIView {
    
    // 서브클래스에서 재정의 가능한 팝업 크기
    var popupWidth: CGFloat { return 250 }
    var popupHeight: CGFloat { return 150 }
    
    // 팝업 콘텐츠 영역
    let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        return view
    }()
    
    var onDismiss: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        setupBase()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 베이스 설정: 콘텐츠 뷰 추가
    private func setupBase() {
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(popupWidth)
            make.height.equalTo(popupHeight)
        }
        // 서브클래스에서 커스터마이징할 수 있도록 기본 콘텐츠 설정 호출
        setupContentView()
    }
    
    // 기본 콘텐츠 설정 (서브클래스에서 오버라이딩 ㄱㄱ)
    func setupContentView() {
        let dismissButton = UIButton(type: .system)
        dismissButton.setTitle("닫기", for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        contentView.addSubview(dismissButton)
        
        dismissButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    // 팝업 표시 메서드
    func show() {
        //guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScene: UIWindowScene? = scenes.first as? UIWindowScene
        guard let window = windowScene?.windows.first else { return }
        
        frame = window.bounds
        alpha = 0
        window.addSubview(self)
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
    
    // 팝업 제거 메서드 (onDismiss 클로저 호출)
    @objc func dismissPopup() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
            self.onDismiss?()
        })
    }
}
