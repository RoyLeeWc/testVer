import UIKit
import ObjectiveC

private var viewTranslationKey: UInt8 = 0

extension UIViewController {
    
    //MARK: 최상단 VC 반환 함수
    
    func getTopViewController() -> UIViewController {
        if let presented = self.presentedViewController {
            return presented.getTopViewController()
        }
        
        if let navigation = self as? UINavigationController, let visible = navigation.visibleViewController {
            return visible.getTopViewController()
        }
        
        if let tab = self as? UITabBarController, let selected = tab.selectedViewController {
            return selected.getTopViewController()
        }
        
        return self
    }
    
    //MARK: 빈화면 탭시 키보드 내리는 확장 함수
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    
    
    
    //MARK: VC 메모리 해제 옵저버
    
    func checkDeallocation(after delay: TimeInterval = 2.0) {
        if isMovingFromParent || isBeingDismissed {
            // ① Array 변환
            // let rootParent = Array(sequence(first: self, next: { $0.parent })).last!
            
            // ② last(where:)
            // let rootParent = sequence(first: self, next: { $0.parent }).last(where: { _ in true })!
            
            // ③ while 루프
            var rootParent = self
            while let parent = rootParent.parent {
                rootParent = parent
            }
            
            let typeName = String(describing: type(of: self))
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                if self != nil {
                    printX("⚠️ \(typeName) 메모리 해제 실패")
                } else {
                    printX("✅ \(typeName) 메모리 해제")
                }
            }
        }
    }
    
    @objc func swizzled_viewDidDisappear(_ animated: Bool) {
        swizzled_viewDidDisappear(animated)  // 원본 호출
        checkDeallocation()
    }

    static func swizzleDeallocCheck() {
        // Method Swizzling 로직
        let original = #selector(viewDidDisappear(_:))
        let swizzled = #selector(swizzled_viewDidDisappear(_:))
        guard
            let originalMethod = class_getInstanceMethod(Self.self, original),
            let swizzledMethod = class_getInstanceMethod(Self.self, swizzled)
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    
    //MARK: 컨텍스트 메뉴 호출
    /// 1) 전달받은 앵커(anchor)에 맞춰서 오버레이(Control) + 드롭다운 메뉴를 띄워준다.
    /// 2) 옵션 변경 시 handler 호출 후 메뉴와 오버레이를 모두 제거한다.
    /// 3) 화면 하단 공간 부족 시, 메뉴를 앵커 위쪽으로 띄우도록 처리.
    func presentDropdownMenu<Option: RawRepresentable & CaseIterable & LZSnackSortOption>(
        anchor: UIView,
        menuWidth: CGFloat = 120,
        current: Option,
        handler: @escaping (Option) -> Void
    ) {
        // 이미 떠 있는 경우 제거
        overlayView?.removeFromSuperview()
        dropdownMenu?.removeFromSuperview()
        
        // ① 오버레이 생성
        let cover = UIControl(frame: view.bounds)
        cover.backgroundColor = .clear
        cover.addTarget(self, action: #selector(dismissDropdown), for: .touchUpInside)
        view.addSubview(cover)
        overlayView = cover
        
        // ② 메뉴 인스턴스 생성
        let menu = LZSnackContextMenu<Option>(current: current) { [weak self] option in
            guard let self = self else { return }
            handler(option)
            self.dismissDropdown()
        }
        dropdownMenu = menu
        
        // 자동 크기 계산을 위해 translatesAutoresizingMaskIntoConstraints = false
        menu.translatesAutoresizingMaskIntoConstraints = false
        cover.addSubview(menu)
        
        // ③ 앵커의 위치를 superview(view) 좌표계로 변환
        let anchorFrame = anchor.convert(anchor.bounds, to: view)
        
        // ④ 가로 위치 계산 (화면 밖 넘치지 않도록)
        var originX = anchorFrame.midX - menuWidth / 2
        originX = min(max(16, originX), view.bounds.width - menuWidth - 16)
        
        // ⑤ 기본: 메뉴를 앵커 하단에 붙임
        //     세로 위치는 4pt 띄우기
        let tentativeY = anchorFrame.maxY + 4
        
        // ⑥ NSLayoutConstraint 설정
        let leading = menu.leadingAnchor.constraint(equalTo: cover.leadingAnchor,
                                                    constant: originX)
        let width   = menu.widthAnchor.constraint(equalToConstant: menuWidth)
        let top     = menu.topAnchor.constraint(equalTo: cover.topAnchor,
                                                constant: tentativeY)
        NSLayoutConstraint.activate([leading, width, top])
        
        // ⑦ Auto Layout을 강제 레이아웃해서 실제 높이를 계산
        cover.layoutIfNeeded()
        let menuHeight = menu.bounds.height
        
        // ⑧ 화면 하단 안전영역과 겹치는지 확인
        let safeAreaBottom = view.safeAreaInsets.bottom
        let maxYAllowed = view.bounds.height - safeAreaBottom - 16
        if anchorFrame.maxY + menuHeight + 4 > maxYAllowed {
            // 메뉴가 아래로 떨어질 공간이 모자람 → 앵커 위쪽으로 띄우기
            NSLayoutConstraint.deactivate([top])
            let newTop = menu.bottomAnchor.constraint(equalTo: cover.topAnchor,
                                                      constant: anchorFrame.minY - 4)
            NSLayoutConstraint.activate([leading, width, newTop])
        }
        
        // 최종 레이아웃 적용
        cover.layoutIfNeeded()
    }
    
    /// 화면 어디를 눌러도 드롭다운 메뉴와 오버레이를 제거한다.
    @objc func dismissDropdown() {
        overlayView?.removeFromSuperview()
        dropdownMenu?.removeFromSuperview()
    }
    
    // == 연관 저장 프로퍼티 작성 == //
    // (실제로는 Associated Object 등을 사용해서 추가해야 하지만, 코드 예시에서는 간단히 전역 변수처럼 가정합니다.)
    private struct AssociatedKeys {
        static var overlayView: UIControl?
        static var dropdownMenu: UIView?
    }
    
    private var overlayView: UIControl? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.overlayView) as? UIControl }
        set { objc_setAssociatedObject(self, &AssociatedKeys.overlayView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private var dropdownMenu: UIView? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.dropdownMenu) as? UIView }
        set { objc_setAssociatedObject(self, &AssociatedKeys.dropdownMenu, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
