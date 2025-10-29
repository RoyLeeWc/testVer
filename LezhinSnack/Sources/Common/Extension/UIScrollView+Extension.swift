//
//  UIScrollView+Extension.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/22/25.
//
import UIKit

extension UIScrollView {
    /// 스크롤뷰를 콘텐츠의 최하단(가장 큰 y)으로 이동
    func scrollToBottom(animated: Bool = true) {
        // 레이아웃 최신화
        self.layoutIfNeeded()
        // 계산된 오프셋 y
        let bottomOffsetY = max(0, contentSize.height - bounds.size.height + contentInset.bottom)
        setContentOffset(CGPoint(x: 0, y: bottomOffsetY), animated: animated)
    }
    
    /// 스크롤뷰에 당겨서 새로고침 컨트롤을 추가하고, 호출할 콜백을 연결합니다.
    /// - Parameters:
    ///   - title: 당겨서 새로고침 중 표시할 문자열(기본값: "당겨서 새로고침")
    ///   - tintColor: 스피너 색상(기본값: 시스템 블루)
    ///   - action: 당겨서 새로고침이 실행되었을 때 호출될 클로저
    /// - Returns: 생성된 UIRefreshControl 인스턴스
    @discardableResult
    func addPullToRefresh(
        title: String = "당겨서 새로고침",
        tintColor: UIColor = .fillBrand,
        action: @escaping () -> Void
    ) -> UIRefreshControl {
        // 1. UIRefreshControl 생성
        let refreshControl = UIRefreshControl()
        
        // 2. 타이틀 및 색상 설정
        //refreshControl.attributedTitle = NSAttributedString(string: title)
        refreshControl.tintColor = tintColor
        
        // 3. iOS 14+ API인 UIAction을 사용해서 콜백 연결
        let actionItem = UIAction { _ in
            action()
        }
        refreshControl.addAction(actionItem, for: .valueChanged)
        
        // 4. 생성한 refreshControl을 스크롤뷰에 할당
        self.refreshControl = refreshControl
        
        return refreshControl
    }
    
    @discardableResult
    func addSafeAreaOffsetPullToRefresh(
        title: String = "당겨서 새로고침",
        tintColor: UIColor = .fillBrand,
        offset: CGFloat = CGFloat(LZSConstant.HomeNavigationBarHeight),
        action: @escaping () -> Void
    ) -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = tintColor
        let actionItem = UIAction { _ in action() }
        refreshControl.addAction(actionItem, for: .valueChanged)
        self.refreshControl = refreshControl

        // offset만큼 당겨서 노출 위치를 조정
        refreshControl.bounds = refreshControl.bounds.offsetBy(dx: 0, dy: -offset)
        return refreshControl
    }
}

