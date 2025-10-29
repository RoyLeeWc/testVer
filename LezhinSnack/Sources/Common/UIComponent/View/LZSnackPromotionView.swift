//
//  LZSnackPromotionView.swift
//  LezhinSnack
//
//  Created by 신진우 on 4/26/25.
//
import UIKit

enum LZSnackPromotionViewType: CaseIterable {
    case originalIcons    // 스낵 오리지널 (여러 뷰)
    case lezhinIPIcons    // 레진 IP (여러 뷰)
    case bomtoonIPIcons   // 봄툰 IP (여러 뷰)

    /// CaseIterable 요구사항 구현
    static var allCases: [LZSnackPromotionViewType] {
        return [
            .originalIcons, .lezhinIPIcons, .bomtoonIPIcons
        ]
    }

    /// 표시할 뷰 배열
    var views: [UIView] {
        switch self {
        case .originalIcons:
            let tagIcon = UIImageView(image: UIImage(named: "ic_tag_snack")?.resized(to: CGSize(width: 20, height: 20)))
            tagIcon.contentMode = .scaleAspectFit
            
            let originalWord = UIImageView(image: UIImage(named: "big_original_word")?.resized(to: CGSize(width: 85, height: 20)))
            originalWord.contentMode = .scaleAspectFit
            originalWord.accessibilityIdentifier = "originalWord"
            
            return [tagIcon, originalWord]
            
        case .lezhinIPIcons:
            let snackTag = UIImageView(image: UIImage(named: "ic_tag_snack")?.resized(to: CGSize(width: 20, height: 20)))
            snackTag.contentMode = .scaleAspectFit
            
            let cross = UIImageView(image: UIImage(named: "ic_x_cross"))
            cross.contentMode = .scaleAspectFit
            
            let lezhinTagView = LZSUtil.makeTagView(type: .lezhin, tagImageSize: CGSize(width: 12, height: 12))
            lezhinTagView.roundCorners(cornerRadius: 2)
            
            let originalWord = UIImageView(image: UIImage(named: "big_original_word")?.resized(to: CGSize(width: 85, height: 20)))
            originalWord.contentMode = .scaleAspectFit
            originalWord.accessibilityIdentifier = "originalWord"
            
            return [snackTag, originalWord, cross, lezhinTagView ]
            
        case .bomtoonIPIcons:
            let snackTag = UIImageView(image: UIImage(named: "ic_tag_snack")?.resized(to: CGSize(width: 20, height: 20)))
            snackTag.contentMode = .scaleAspectFit
            
            let cross = UIImageView(image: UIImage(named: "ic_x_cross"))
            cross.contentMode = .scaleAspectFit
            
            let bomtoonTagView = LZSUtil.makeTagView(type: .bomtoon, tagImageSize: CGSize(width: 12, height: 12))
            bomtoonTagView.roundCorners(cornerRadius: 2)
            
            let originalWord = UIImageView(image: UIImage(named: "big_original_word")?.resized(to: CGSize(width: 85, height: 20)))
            originalWord.contentMode = .scaleAspectFit
            originalWord.accessibilityIdentifier = "originalWord"
            
            return [snackTag, originalWord, cross, bomtoonTagView]
        }
    }
}

/// 프로모션 뷰
final class LZSnackPromotionView: UIView {
    let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let markType: LZSnackPromotionViewType
    
    private let leadingTrailingInset: Int
    
    
    init(type: LZSnackPromotionViewType,
         leadingTrailingInset: Int = 0 ) {
        self.markType = type
        self.leadingTrailingInset = leadingTrailingInset
        super.init(frame: .zero)
        
        // 1) 스택뷰 설정
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        // 2) 아이콘과 타이틀을 모두 스택뷰에 추가
        type.views.forEach { view in
            if let iv = view as? UIImageView, let img = iv.image {
                iv.contentMode = .scaleAspectFit
                iv.snp.makeConstraints { make in
                    make.height.equalTo(20)
                    make.width.equalTo(iv.snp.height).multipliedBy(img.size.width / img.size.height)
                }
            } else {
                view.snp.makeConstraints { make in
                    make.width.height.equalTo(20)
                }
            }
            stackView.addArrangedSubview(view)
        }
        
        backgroundColor = UIColor(.clear)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}
