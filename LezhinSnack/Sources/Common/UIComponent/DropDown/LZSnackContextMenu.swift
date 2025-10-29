//
//  SortDropdownMenuView.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/17/25.
//

import UIKit

final class LZSnackContextMenu<Option: RawRepresentable & CaseIterable & LZSnackSortOption>: UIView
where Option.RawValue == String {
    
    private let current: Option
    private let handler: (Option) -> Void
    
    init(current: Option,
         handler: @escaping (Option) -> Void) {
        self.current  = current
        self.handler  = handler
        super.init(frame: .zero)
        configureUI()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override var intrinsicContentSize: CGSize {
        let count = Option.allCases.count
        
        // 예: 메뉴 개수에 따라 고정 높이 지정
        let height: CGFloat
        switch count {
        case 2:
            height = 83
        case 3:
            height = 128
        default:
            // 기본값으로 버튼 콘텐츠 기반 자동 계산
            let buttonsHeight = Option.allCases.reduce(0) { total, option in
                let btn = UIButton(type: .system)
                btn.setTitle(option.rawValue, for: .normal)
                btn.titleLabel?.font = .pretendardRegular(size: 14)
                btn.contentEdgeInsets = .init(top: 12, left: 16, bottom: 12, right: 16)
                return total + btn.sizeThatFits(.init(width: bounds.width, height: .greatestFiniteMagnitude)).height
            }
            let dividersHeight = CGFloat(max(0, count - 1))
            height = buttonsHeight + dividersHeight
        }
        
        return .init(width: UIView.noIntrinsicMetric, height: height)
    }
    
    private func configureUI() {
        backgroundColor = UIColor(.backgroundOverlay)
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        let stack = UIStackView()
        stack.axis         = .vertical
        stack.alignment    = .fill       // 뷰 너비를 스택 너비에 맞춤
        stack.distribution = .fill       // intrinsic size 기반으로 채움
        stack.spacing      = 0           // 아이템 간 여백은 divider로 처리
        
        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        Option.allCases.enumerated().forEach { idx, option in
            let button = UIButton(type: .system)
            button.setTitle(option.rawValue.localized, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .pretendardRegular(size: 14)
            button.contentHorizontalAlignment = .left
            button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16,
                                                    bottom: 12, right: 16)
            button.addAction(.init { [weak self] _ in
                self?.handler(option)
            }, for: .touchUpInside)
            stack.addArrangedSubview(button)
            
            if idx < Option.allCases.count - 1 {
                let divider = UIView()
                divider.backgroundColor = UIColor(.borderDefault)
                stack.addArrangedSubview(divider)
                divider.snp.makeConstraints { make in
                    make.height.equalTo(1)
                    make.leading.trailing.equalToSuperview()
                }
            }
        }
    }
}
