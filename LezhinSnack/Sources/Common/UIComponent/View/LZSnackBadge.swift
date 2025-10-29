//
//  LZSnackBadge.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/19/25.
//


import UIKit
import SnapKit

enum LZSnackBadgeType: CaseIterable {
    case top10, new, event, up

    static var allCases: [LZSnackBadgeType] { [.top10, .new, .event, .up] }

    var backgroundColor: UIColor {
        switch self {
        case .top10, .new:   return .fillInverse
        case .event, .up:    return .fillBrand
        }
    }

    var imageName: String {
        switch self {
        case .top10: return "topTag"
        case .new:   return "newTag"
        case .event: return "eventTag"
        case .up:    return "upTag"
        }
    }

    /// 전체 뷰 너비 (이미지 + 좌우 패딩)
    var width: CGFloat {
        switch self {
        case .top10: return 36
        case .new:   return 30
        case .event: return 34
        case .up:    return 18
        }
    }
}

final class LZSnackBadge: UIView {
    private let imageView = UIImageView()

    init(type: LZSnackBadgeType) {
        super.init(frame: .zero)
        backgroundColor = type.backgroundColor
        layer.cornerRadius = 4
        clipsToBounds = true

        addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: type.imageName)

        // SnapKit으로 패딩 및 고정 크기 설정
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(4)
            make.trailing.equalToSuperview().inset(4)
            make.top.equalToSuperview().offset(2)
            make.bottom.equalToSuperview().inset(2)
        }

        snp.makeConstraints { make in
            make.width.equalTo(type.width)
            make.height.equalTo(16)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("스토리보드/IB 지원하지 않음")
    }
}


final class LZSnackBadgeStackView: UIStackView {

    init(types: [LZSnackBadgeType]) {
        super.init(frame: .zero)
        
        axis         = .horizontal
        alignment    = .center       // 수직 중앙 정렬
        distribution = .fill         // 스페이서가 남는 공간 채움
        spacing      = 2             // 뱃지 간 2pt 간격
        
        // 1. 왼쪽에 유연한 스페이서 추가
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        // 스페이서는 가능한만큼 늘어나도록 허용
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addArrangedSubview(spacer)
        
        // 2. 타입별 뱃지 추가
        types.forEach { type in
            let badge = LZSnackBadge(type: type)
            // 뱃지는 절대 늘어나지 않도록 우선순위 높임
            badge.setContentHuggingPriority(.required, for: .horizontal)
            badge.setContentCompressionResistancePriority(.required, for: .horizontal)
            addArrangedSubview(badge)
        }
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("스토리보드 지원하지 않음")
    }
}

extension LZSnackBadgeType {
    init?(mark: MarkEntity) { self.init(markType: mark.type) }

    init?(markType: MarkType) {
        switch markType {
        case .new:   self = .new
        case .up:    self = .up
        case .top10: self = .top10
        case .unknown: return nil
        }
    }
}
