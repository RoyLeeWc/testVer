//
//  AllContentsHeaderView.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/17/25.
//

import UIKit


// MARK: - 델리게이트
protocol AllContentsHeaderViewDelegate: AnyObject {
    func allContentsHeaderViewDidTapSortButton(_ header: AllContentsHeaderView,
                                               anchor: UIView)
}

// Height = 56
final class AllContentsHeaderView: UICollectionReusableView {
    
    weak var delegate: AllContentsHeaderViewDelegate?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardSemiBold(size: 18)
        label.textColor = .white
        label.numberOfLines = 0
        label.text = "originalHeaderTitle".dynamicLocalized
        return label
    }()
    
    private let sortButton: LZSnackSortButton = {
        let button = LZSnackSortButton(option: AllContentsSortOption.like)
        guard let rawIcon = UIImage(named: "ic_sort")?.withRenderingMode(.alwaysOriginal) else { return button }
        let smallIcon = rawIcon.resized(to: CGSize(width: 14, height: 14))?.withRenderingMode(.alwaysOriginal)
        let customStyle = LZSnackSortButton.Style(icon: smallIcon,
                                                  font: .pretendardMedium(size: 13),
                                                  textColor: .foregroundSubtler
        )
        
        button.applyStyle(customStyle)
        button.contentHorizontalAlignment = .right
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        //configureMenu(with: .like)     // 기본값
        sortButton.setTitle(AllContentsSortOption.like.displayName, for: .normal)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
//        sortButton.setContentHuggingPriority(.required, for: .horizontal)
//        sortButton.setContentCompressionResistancePriority(.required, for: .horizontal)
//        
//        addSubview(sortButton)
//        sortButton.snp.makeConstraints { make in
//            make.trailing.equalToSuperview().offset(-20)
//            make.width.equalTo(120)
//            make.centerY.equalToSuperview()
//        }
        
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(28)
            make.centerY.equalToSuperview()
        }
        
//        sortButton.addTarget(self, action: #selector(didTapSortButton), for: .touchUpInside)
        
    }
    
    
    @objc private func didTapSortButton() {
        delegate?.allContentsHeaderViewDidTapSortButton(self, anchor: sortButton)
    }
    
    /// 외부에서 버튼 타이틀을 갱신할 때 호출
    func updateSortTitle(_ option: AllContentsSortOption) {
        sortButton.setTitle(option.displayName, for: .normal)
        sortButton.invalidateIntrinsicContentSize()
        sortButton.setNeedsLayout()
        sortButton.setNeedsDisplay()
    }
    
}
