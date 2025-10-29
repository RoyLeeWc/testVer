//
//  FAQListCell.swift
//  LezhinSnack
//
//  Created by lwc on 10/20/25.
//

import UIKit

final class FAQListCell: UITableViewCell {
    static let reuseID = "FAQListCell"

    private let normalBG = UIColor(.backgroundDefault)
    private let pressedBG = UIColor(red: 0.07, green: 0.07, blue: 0.08, alpha: 1.0)
    
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.font = .pretendardMedium(size: 16)
        lb.textColor = .white
        lb.numberOfLines = 2
        return lb
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

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
    
    func configure(question: String) {
        titleLabel.text = question
    }
}
