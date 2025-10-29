// RecommendCell.swift
// LezhinSnack
//
// Created by jinu0115 on 5/7/25.
//
import UIKit
import SnapKit

final class RecommendVideoCell: UICollectionViewCell {
    // MARK: - Subviews
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let titleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var promotionBadgeView: LZSnackPromotionView?

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup
    private func setupUI() {
        contentView.backgroundColor = .lightGray
        contentView.roundCorners(cornerRadius: 12)

        contentView.addSubview(thumbnailImageView)
        thumbnailImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        thumbnailImageView.roundCorners(cornerRadius: 12)

        contentView.addSubview(titleImageView)
        titleImageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().inset(32)
        }
    }

    // MARK: - Configuration
    func configure(with title: String) {
        thumbnailImageView.image = UIImage(named: "BannerMock")
        titleImageView.image = UIImage(named: "mainBannerTitle")

        // 기존 프로모션 뱃지 제거
        promotionBadgeView?.removeFromSuperview()

        // 새로운 프로모션 뱃지 추가
        let newBadge = LZSnackPromotionView(type: .allCases.randomElement()!)
        promotionBadgeView = newBadge
        contentView.addSubview(newBadge)
        newBadge.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
            make.bottom.equalTo(titleImageView.snp.top).offset(-12)
        }
    }

    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.transform = .identity

        // 재사용 시 프로모션 뱃지 초기화
        promotionBadgeView?.removeFromSuperview()
        promotionBadgeView = nil
    }
}
