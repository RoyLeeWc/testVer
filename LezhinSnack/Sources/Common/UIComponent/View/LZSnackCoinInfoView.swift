//
//  LZSnackCoinInfoView.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/23/25.
//

import UIKit
import SnapKit

final class LZSnackCoinInfoView: UIView {
    // MARK: - Subviews
    private let coinIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_coin")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let coinInfoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .pretendardSemiBold(size: 16)
        return label
    }()

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - UI Setup
    private func setupUI() {
        addSubview(coinIconImageView)
        addSubview(coinInfoLabel)

        // 레이아웃 설정
        coinIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16.7)
        }

        coinInfoLabel.snp.makeConstraints { make in
            make.leading.equalTo(coinIconImageView.snp.trailing).offset(2)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }

    // MARK: - Public Configuration
    /// 코인 수량 또는 정보를 설정합니다.
    func setCoinText(_ text: String) {
        coinInfoLabel.text = text
    }
    
    func setCoinImageSize(size: CGSize) {
        coinIconImageView.snp.updateConstraints { make in
            make.size.equalTo(size)
        }
    }
}
