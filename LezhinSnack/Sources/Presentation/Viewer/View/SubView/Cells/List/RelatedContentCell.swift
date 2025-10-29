//
//  RelatedContentCell.swift
//  LezhinSnack
//
//  Created by 신진우 on 4/20/25.
//
import UIKit
import SnapKit

final class RelatedContentCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 16)
        label.textColor = .white
        label.numberOfLines = 0
        
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        
        return label
    }()
    
    private let episodeInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 13)
        label.textColor = UIColor(.foregroundSubtler)
        label.numberOfLines = 0
        return label
    }()
    
    
    private func setupUI() {
        // 모든 서브뷰 addSubview
        [thumbnailImageView, titleLabel, episodeInfoLabel].forEach {
            contentView.addSubview($0)
        }

        // 썸네일 제약
        thumbnailImageView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.width.equalTo(54)
        }
        
        thumbnailImageView.image = UIImage(named: "mock_small_thumbnail")
        thumbnailImageView.roundCorners(cornerRadius: 4)
        // 타이틀 제약
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(thumbnailImageView.snp.top).offset(2)
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(16)
        }

        // 에피소드 정보
        episodeInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalTo(titleLabel.snp.trailing)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    
    func configure() {
        titleLabel.text = "[스틸 촬영] 제작현장 비하인드"
        episodeInfoLabel.text = "2025 숏폼 영상 최고 화제작! 2025 숏폼 영상 최고 화제작! 2025 숏폼 영상 최고 화제작!2025 숏폼 영상 최고 화제작! 2025 숏폼 영상 최고 화제작! 2025 숏폼 영상 최고 화제작!2025 숏폼 영상 최고 화제작! 2025 숏폼 영상 최고 화제작! 2025 숏폼 영상 최고 화제작!2025 숏폼 영상 최고 화제작! 2025 숏폼 영상 최고 화제작! 2025 숏폼 영상 최고 화제작!"
    }
}

