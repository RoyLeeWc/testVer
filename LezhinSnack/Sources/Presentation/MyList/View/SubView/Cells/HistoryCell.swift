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
    
    private func syncSelectionUI() {
        if isEditingMode {
            checkBox.setState(isSelected ? .checked : .unchecked)
            thumbnailImageView.alpha = isSelected ? 1.0 : 0.3
        } else {
            checkBox.setState(.unchecked)
            thumbnailImageView.alpha = 1.0      // 일반 모드: 항상 진하게
        }
    }
    
    override var isSelected: Bool {
        didSet { syncSelectionUI() }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isSelected = false
        syncSelectionUI()
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
        label.numberOfLines = 1
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
        thumbnailImageView.alpha = isEditingMode ? (isSelected ? 1.0 : 0.3) : 1.0

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
    
    func configure(with entity: LastViewedContentItemEntity) {
        thumbnailImageView.kf.setImage(with: URL(string: entity.thumbnailUrl))
        titleLabel.text = entity.title
        let lastviewedEpisodeNumber = String(entity.lastViewedEpisodeNumber)
        let lastepisodeNumber = String(entity.lastEpisodeNumber)
        
        // 분리한 텍스트 요소
        let firstPart = "\(lastviewedEpisodeNumber)회"      // "1화"
        let secondPart = "\(lastepisodeNumber)회"       // "82화"

        let resultAttributedText = NSMutableAttributedString()
        let firstAttributed = NSAttributedString(string: firstPart, attributes: [.foregroundColor: UIColor.white])
        resultAttributedText.append(firstAttributed)
        let secondAttributed = NSAttributedString(string: " / " + secondPart, attributes: [.foregroundColor: UIColor(.foregroundSubtler)])
        resultAttributedText.append(secondAttributed)
        
        episodeInfoLabel.attributedText = resultAttributedText
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let watchedDate = dateFormatter.string(from: entity.lastViewedAt)
        watchedDateLabel.text = watchedDate
        
        let progressValue: Float = episodeProgress(lastViewedEpisodeNumber: entity.lastViewedEpisodeNumber, lastEpisodeNumber: entity.lastEpisodeNumber)
        progressView.setProgress(progressValue, animated: false)
        
    }
    
    func episodeProgress(lastViewedEpisodeNumber: Int?, lastEpisodeNumber: Int?) -> Float {
        guard var last = lastEpisodeNumber, var current = lastViewedEpisodeNumber else { return 0 }
        // 음수 방지
        last = max(0, last)
        current = max(0, current)

        // 0-based/1-based 추론: 값 중 하나라도 0이면 0부터 시작한다고 가정
        let first = (last == 0 || current == 0) ? 0 : 1

        // 전체 회차 수 (= first...last 포함 개수)
        let totalCount = last - first + 1
        guard totalCount > 0 else { return 0 }

        // 현재 시청 회차를 first...last 범위로 클램프
        let clampedCurrent = min(max(current, first), last)

        // '본 회차 수'(첫 회차도 1로 계산) / '전체 회차 수'
        let watchedCount = clampedCurrent - first + 1
        return Float(watchedCount) / Float(totalCount)
    }
}
