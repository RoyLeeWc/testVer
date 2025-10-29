//
//  HistoryCell.swift
//  LezhinSnack
//
//  Created by 신진우 on 4/20/25.
//
import UIKit
import SnapKit

final class HistoryCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    var isEditingMode: Bool = false {
        didSet {
            updateEditingMode()
        }
    }
    
    private var progressHeightConstraint: Constraint?
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                contentView.alpha = 1.0
                checkBox.setState(.checked)
            } else {
                contentView.alpha = 0.3
                checkBox.setState(.unchecked)
            }
        }
    }
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 18)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let episodeInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 14)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressTintColor = UIColor(.brandRed)
        progressView.trackTintColor = UIColor(.fillSubtler)
        return progressView
    }()
    
    private let watchedDateLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 13)
        label.textColor = UIColor(.foregroundSubtler)
        label.numberOfLines = 0
        return label
    }()
    
    
    private let checkBox: LZSnackCheckBox = {
        let checkBox = LZSnackCheckBox()
        checkBox.isUserInteractionEnabled = false
        return checkBox
    }()
    
    
    
    func updateEditingMode() {
        // 체크박스
        checkBox.isHidden = !isEditingMode

        // progressView 높이 0 또는 4
        let height: CGFloat = isEditingMode ? 0 : 4
        progressHeightConstraint?.update(offset: height)

        // 셀 dimming
        contentView.alpha = isEditingMode
            ? (isSelected ? 1.0 : 0.3)
            : 1.0

        // 즉시 레이아웃 반영
        contentView.layoutIfNeeded()
    }
    
    private func setupUI() {
        contentView.addSubview(thumbnailImageView)
        thumbnailImageView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.equalToSuperview().offset(16)
            make.width.equalTo(64)
        }
        thumbnailImageView.roundCorners(cornerRadius: 4)
        
        contentView.addSubview(checkBox)
        checkBox.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(24)
            make.trailing.equalToSuperview().inset(16)
        }
        
        checkBox.isHidden = true
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(16)
            make.trailing.equalTo(checkBox.snp.leading).offset(12)
        }
        
        contentView.addSubview(episodeInfoLabel)
        episodeInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(16)
            make.trailing.equalTo(checkBox.snp.leading).offset(12)
        }
        
        contentView.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.top.equalTo(episodeInfoLabel.snp.bottom).offset(8)
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(16)
            progressHeightConstraint = make.height.equalTo(4).constraint
        }
        progressView.roundCorners(cornerRadius: 2)
               
        contentView.addSubview(watchedDateLabel)
        watchedDateLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(8)
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(16)
            make.trailing.equalTo(checkBox.snp.leading).offset(-12)
            make.bottom.equalToSuperview().inset(8)
        }
        
    }
    
    func configure(with entity: WatchHistoryEntity) {
        thumbnailImageView.image = UIImage(named: entity.thumbnailIUrl )
        titleLabel.text = entity.title
        episodeInfoLabel.text = "\(entity.watchedEpisode)회 / \(entity.totalEpisodeCount)회"
        watchedDateLabel.text = entity.watchedDate
        progressView.setProgress(entity.viewingRate, animated: false)
    }
    
    func updateRandomProgress() {
        // 0.0부터 1.0 사이의 랜덤 Float 값 생성
        let randomProgress = Float.random(in: 0...1)
        
        // progressView의 progress를 애니메이션과 함께 업데이트
        progressView.setProgress(randomProgress, animated: false)
    }
}
