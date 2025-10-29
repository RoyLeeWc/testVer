//
//  NoticeListCell.swift
//  LezhinSnack
//
//  Created by lwc on 10/20/25.
//
import UIKit
import SnapKit

final class NoticeListCell: UITableViewCell {
    static let reuseID = "NoticeListCell"

    private let normalBG = UIColor(.backgroundDefault)
    private let pressedBG = UIColor(red: 0.07, green: 0.07, blue: 0.08, alpha: 1.0)
    
    private let categoryTitleLabel: UILabel = {
        let lb = UILabel()
        lb.font = .pretendardRegular(size: 14)
        lb.textColor = UIColor(.foregroundBrand)
        lb.numberOfLines = 2
        return lb
    }()

    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.font = .pretendardMedium(size: 16)
        lb.textColor = .white
        lb.numberOfLines = 2
        return lb
    }()

    private let newBadge: UILabel = {
        let lb = LZSnackPaddingLabel()
        lb.textInsets = .init(top: 2, left: 6, bottom: 2, right: 6)
        lb.font = .pretendardMedium(size: 11)
        lb.text = "New"
        lb.textColor = .white
        lb.backgroundColor = UIColor(.fillBrand)
        lb.roundCorners(cornerRadius: 4)
        lb.isHidden = true
        return lb
    }()

    private let dateLabel: UILabel = {
        let lb = UILabel()
        lb.font = .pretendardRegular(size: 13)
        lb.textColor = UIColor(.foregroundSubtler)
        return lb
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(categoryTitleLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(newBadge)

        // 배지: 우측 고정 + 가운데 정렬
        newBadge.setContentCompressionResistancePriority(.required, for: .horizontal)
        newBadge.setContentHuggingPriority(.required, for: .horizontal)
        newBadge.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(24)
            make.trailing.equalToSuperview().inset(16)   // 오른쪽에서 16
        }

        categoryTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(16)
            make.trailing.lessThanOrEqualTo(newBadge.snp.leading).offset(-12)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryTitleLabel.snp.bottom).offset(0)
            make.leading.equalToSuperview().inset(16)
            make.trailing.lessThanOrEqualTo(newBadge.snp.leading).offset(-12)
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().inset(16)
            make.trailing.lessThanOrEqualTo(newBadge.snp.leading).offset(-12)
            make.bottom.equalToSuperview().inset(16)
        }

        // 최소 높이(1줄 기준)
        contentView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(100)
            make.width.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(_ item: NoticeListEntity) {
        categoryTitleLabel.text = item.categoryTitle
        titleLabel.text = item.title
        dateLabel.text  = format(item.createdAt)
        newBadge.isHidden = !item.isPinned 
    }
    

    private func format(_ ms: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(ms) / 1000.0)
        let f = DateFormatter()
        f.locale = .current
        f.timeZone = .current
        f.dateFormat = "yyyy.MM.dd"
        return f.string(from: date)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let apply = { self.contentView.backgroundColor = highlighted ? self.pressedBG : self.normalBG }
        
        if highlighted {
            UIView.performWithoutAnimation {
                apply()
                self.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.12,
                           delay: 0,
                           options: [.beginFromCurrentState, .allowUserInteraction]) {
                apply()
            }
        }
        super.setHighlighted(highlighted, animated: animated)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.backgroundColor = normalBG
    }
    
}
