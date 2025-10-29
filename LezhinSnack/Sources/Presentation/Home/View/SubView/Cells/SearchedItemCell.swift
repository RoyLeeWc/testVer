//
//  SearchedItemCell.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/26/25.
//

import UIKit
import SnapKit

final class SearchedItemCell: UICollectionViewCell {
    
    private var highlightKeyword: String?
    
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
    
    private var tagView: LZSnackSearchTagContainerView = {
        let view = LZSnackSearchTagContainerView()
        return view
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.attributedText = nil
        episodeInfoLabel.attributedText = nil
    }
    
    private func setupUI() {
        // 모든 서브뷰 addSubview
        [thumbnailImageView, titleLabel, episodeInfoLabel, tagView].forEach {
            contentView.addSubview($0)
        }

        // 썸네일 제약
        thumbnailImageView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.width.equalTo(64)
        }
        
        thumbnailImageView.image = UIImage(named: "mock_small_thumbnail")
        thumbnailImageView.roundCorners(cornerRadius: 4)
        // 타이틀 제약
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(thumbnailImageView.snp.top).offset(3)
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(16)
        }

        // 에피소드 정보
        episodeInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalTo(titleLabel.snp.trailing)
            make.height.equalTo(36)
        }
        
        tagView.snp.makeConstraints { make in
            make.top.equalTo(episodeInfoLabel.snp.bottom).offset(8)
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalTo(titleLabel.snp.trailing)
            make.bottom.equalToSuperview().inset(3)
        }
        
        
    }
    
    func configure(item: SearchContent, keyword: String?) {
//        titleLabel.text = item.title
        let desc = "2025 숏폼 영상 최고 화제작! 2025 숏폼 영상 최고 화제작! 2025 숏폼 영상 최고 화제작!2025 숏폼 영상 최고 화제작! 2025 숏폼 영상 최고 화제작! 2025 숏폼 영상 최고 화제작!2025 숏폼 영상 최고 화제작! 2025 숏폼 영상 최고 화제작! 2025 숏폼 영상 최고 화제작!2025 숏폼 영상 최고 화제작! 2025 숏폼 영상 최고 화제작! 2025 숏폼 영상 최고 화제작!"
        highlightKeyword = keyword
        
        
        titleLabel.setText(item.title, highlight: keyword, lineHeight: 22)
        episodeInfoLabel.setText(desc, highlight: keyword, lineHeight: 18)

        if let thumbnailPath = item.thumbnails?.first?.imagePath,
           let url = URL(string: thumbnailPath) {
            thumbnailImageView.kf.setImage(with: url)
        } else {
            thumbnailImageView.image = nil
        }
        
        
        guard let tagsArray = item.tag?.components(separatedBy: ",") else { return }
        tagView.applyItemTagTitles(tagsArray,highlight: keyword)
        
    }
}

