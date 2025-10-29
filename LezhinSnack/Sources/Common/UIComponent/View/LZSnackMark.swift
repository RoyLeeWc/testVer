//
//  LZSnackMark.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/25/25.
//

import UIKit
import SnapKit

/// 마크 종류 정의
enum LZSnackMarkType: CaseIterable {
    case ranking          // Top10 진입
    case newWork          // 화제의 신작
    case popularBest      // 인기 급상승
    case wishBest         // 찜 BEST
    case favoriteBest     // 좋아요 BEST
    case originalIcons    // 스낵 오리지널 (여러 뷰)
    case lezhinIPIcons    // 레진 IP (여러 뷰)
    case bomtoonIPIcons   // 봄툰 IP (여러 뷰)
    case custom(views: [UIView], title: String?) // 커스텀 뷰 및 선택적 타이틀

    /// CaseIterable 요구사항 구현
    static var allCases: [LZSnackMarkType] {
        return [
            .ranking, .newWork, .popularBest, .wishBest,
            .favoriteBest, .originalIcons, .lezhinIPIcons, .bomtoonIPIcons
        ]
    }

    /// 표시할 뷰 배열
    var views: [UIView] {
        switch self {
        case .ranking:
            let imageView = UIImageView(image: UIImage(named: "ic_crown_color"))
            imageView.contentMode = .scaleAspectFit
            return [imageView]
        case .newWork:
            let imageView = UIImageView(image: UIImage(named: "ic_fire_color"))
            imageView.contentMode = .scaleAspectFit
            return [imageView]
        case .popularBest:
            let imageView = UIImageView(image: UIImage(named: "ic_fluctuation_color"))
            imageView.contentMode = .scaleAspectFit
            return [imageView]
        case .wishBest:
            let imageView = UIImageView(image: UIImage(named: "ic_bookmark_color"))
            imageView.contentMode = .scaleAspectFit
            return [imageView]
        case .favoriteBest:
            let imageView = UIImageView(image: UIImage(named: "ic_heart_fill"))
            imageView.contentMode = .scaleAspectFit
            return [imageView]
        case .originalIcons:
            let tagIcon = UIImageView(image: UIImage(named: "ic_tag_snack")?.resized(to: CGSize(width: 12, height: 12)))
            tagIcon.contentMode = .scaleAspectFit

            let wordIcon = UIImageView(image: UIImage(named: "original_word")?.resized(to: CGSize(width: 51, height: 12)))
            wordIcon.contentMode = .scaleAspectFit
            wordIcon.accessibilityIdentifier = "originalWord"

            return [tagIcon, wordIcon]

        case .lezhinIPIcons:
            let snackTag = UIImageView(image: UIImage(named: "ic_tag_snack")?.resized(to: CGSize(width: 12, height: 12)))
            snackTag.contentMode = .scaleAspectFit

            let cross = UIImageView(image: UIImage(named: "ic_x_cross"))
            cross.contentMode = .scaleAspectFit

            let lezhinTagView = LZSUtil.makeTagView(type: .lezhin, tagImageSize: CGSize(width: 10, height: 10))
            lezhinTagView.roundCorners(cornerRadius: 2)
            
            let wordIcon = UIImageView(image: UIImage(named: "lezhin_word"))
            wordIcon.contentMode = .scaleAspectFit
            wordIcon.accessibilityIdentifier = "word"

            return [snackTag, cross, lezhinTagView, wordIcon]

        case .bomtoonIPIcons:
            let snackTag = UIImageView(image: UIImage(named: "ic_tag_snack")?.resized(to: CGSize(width: 12, height: 12)))
            snackTag.contentMode = .scaleAspectFit

            let cross = UIImageView(image: UIImage(named: "ic_x_cross"))
            cross.contentMode = .scaleAspectFit

            let bomtoonTagView = LZSUtil.makeTagView(type: .bomtoon, tagImageSize: CGSize(width: 10, height: 10))
            bomtoonTagView.roundCorners(cornerRadius: 2)

            let wordIcon = UIImageView(image: UIImage(named: "bomtoon_word"))
            wordIcon.contentMode = .scaleAspectFit
            wordIcon.accessibilityIdentifier = "word"

            return [snackTag, cross, bomtoonTagView, wordIcon]
        case .custom(let views, _):
            return views
        }
    }

    /// 표시할 텍스트 (없으면 nil)
    var title: String? {
        switch self {
        case .ranking:
            return "Top10 진입"
        case .newWork:
            return "화제의 신작"
        case .popularBest:
            return "인기 급상승"
        case .wishBest:
            return "찜 BEST"
        case .favoriteBest:
            return "좋아요 BEST"
        case .custom(_, let title):
            return title
        default:
            return nil
        }
    }

    /// 배경 색
    var backgroundColor: UIColor {
        return UIColor(.darkGray333)
    }

    /// 텍스트 색
    var textColor: UIColor {
        return .white
    }
}

/// 마크 뷰
final class LZSnackMarkView: UIView {
    let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let markType: LZSnackMarkType
    
    private let leadingTrailingInset: Int
    private let fontSize: CGFloat
    
    
    init(type: LZSnackMarkType,
         leadingTrailingInset: Int = 4,
         fontSize: CGFloat = 12 ) {
        self.markType = type
        self.leadingTrailingInset = leadingTrailingInset
        self.fontSize = fontSize
        super.init(frame: .zero)
        
        // 1) 스택뷰 설정
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 2
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(leadingTrailingInset)
            make.top.bottom.equalToSuperview().inset(2)
        }
        
        // 2) 아이콘과 타이틀을 모두 스택뷰에 추가
        type.views.forEach { view in
            if let iv = view as? UIImageView, let img = iv.image {
                iv.contentMode = .scaleAspectFit
                iv.snp.makeConstraints { make in
                    make.height.equalTo(getImageHeight(for: iv))
                    make.width.equalTo(iv.snp.height).multipliedBy(img.size.width / img.size.height)
                }
            } else {
                view.snp.makeConstraints { make in
                    make.width.height.equalTo(16)
                }
            }
            stackView.addArrangedSubview(view)
        }
        
        if let text = type.title {
            let label = UILabel()
            label.text = text
            label.font = .pretendardMedium(size: fontSize)
            label.textColor = .white
            stackView.addArrangedSubview(label)
        }
        
        backgroundColor = UIColor(.backgroundOverlay)
        layer.cornerRadius = 4
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func getImageHeight(for iv: UIImageView) -> CGFloat {
        switch iv.accessibilityIdentifier {
        case "originalWord": return 12
        case "word": return 10
        default: return 16
        }
    }
}

extension LZSnackMarkType {
    /// BadgeEntity 바로 받기
    init?(badge: BadgeEntity) {
        self.init(badgeType: badge.type.rawValue)
    }
    /// BadgeType 바로 받기
    init?(badgeType: BadgeType) {
        self.init(badgeType: badgeType.rawValue)
    }
    /// 서버 badgeType 문자열을 UI 마크 타입으로 변환
    init?(badgeType: String) {
        switch badgeType.uppercased() {
        case "LEZHIN_ORIGINAL":
            self = .lezhinIPIcons
        case "BOMTOON_ORIGINAL":
            self = .bomtoonIPIcons
        case "GENERAL_ORIGINAL":
            self = .originalIcons
        case "TOP_10_ENTRY":
            self = .ranking
        case "RISING_POPULARITY":
            self = .popularBest
        case "NEW_RELEASE":
            self = .newWork
        case "LIKE_BEST":
            self = .wishBest
        case "FAVORITE_BEST":
            self = .favoriteBest
        default:
            return nil
        }
    }
}
