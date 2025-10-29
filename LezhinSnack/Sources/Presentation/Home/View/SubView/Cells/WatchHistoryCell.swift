//
//  WatchHistoryCell.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/15/25.
//

import UIKit

final class WatchHistoryCell: UICollectionViewCell {
    
    let thumbImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressTintColor = UIColor(.snackBrandRed)
        progressView.trackTintColor = UIColor(.baseBlack)
        return progressView
    }()
    
    let playButtonContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(.blackOpacity52)
        return view
    }()
    
    
    let playButtonImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ic_play_fill"))
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()  // 셀 내부 뷰들을 추가 및 제약조건 설정
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:)는 지원하지 않습니다. 코드 기반으로 구현해 주세요.")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    func reset() {
        // 이전 상태 정리
        thumbImageView.image = nil
    }
    
    private func setupUI() {
        
        isSkeletonable = true
        
        contentView.addSubview(thumbImageView)
        thumbImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(150)
        }
        
        
        thumbImageView.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.height.equalTo(4)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        thumbImageView.roundCorners(cornerRadius: 4)

        thumbImageView.backgroundColor = UIColor(.darkGray333)
        
        thumbImageView.addSubview(playButtonContainerView)
        playButtonContainerView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.centerX.centerY.equalToSuperview()
        }
        playButtonContainerView.roundCorners(cornerRadius: 20)
        
        
        playButtonContainerView.addSubview(playButtonImageView)
        playButtonImageView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.centerX.centerY.equalToSuperview()
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(thumbImageView.snp.bottom).offset(4)
        }
        
        
    }
    
    func configure(lastWatch: ContentsLastWatchItemEntity) {
       
        if let urlStr = lastWatch.thumbnailUrl, let url = URL(string: urlStr) {
            thumbImageView.kf.setImage(with: url)
        } else {
            thumbImageView.image = nil
        }
        
        let currentText = lastWatch.currentEpisode.map(String.init) ?? "-"
        let maxText     = lastWatch.maxEpisode.map(String.init) ?? "-"
        let fullText    = "\(currentText)화 / \(maxText)화"

        let episProgress = episodeProgress(current: lastWatch.currentEpisode, total: lastWatch.maxEpisode)
        updateRandomProgress(progressVal:episProgress)
        setTitleLabelTextColor(fullText)
        showAnimatedGradientSkeleton(isPlaceholder: false)
    }

    
    func configure(_ data: HomeSectionEntity) {
        showAnimatedGradientSkeleton(isPlaceholder: data.isPlaceholder)
    }
    
    func setTitleLabelTextColor(_ text: String) {

        // "/"를 기준으로 문자열을 분리 (앞뒤 공백 제거)
        let components = text.components(separatedBy: "/").map { $0.trimmingCharacters(in: .whitespaces) }

        guard components.count == 2 else {
            // "/" 구분자로 나눌 수 없으면 기본 white 색상 적용 후 반환
            let attributedText = NSAttributedString(string: text,
                                                    attributes: [.foregroundColor: UIColor(.foregroundSubtler)])
            titleLabel.attributedText = attributedText
            return
        }

        // 분리한 텍스트 요소
        let firstPart = components[0]        // "1화"
        let secondPart = components[1]       // "82화"

        let resultAttributedText = NSMutableAttributedString()
        

        let firstAttributed = NSAttributedString(string: firstPart, attributes: [.foregroundColor: UIColor(.foregroundBrand)])
        resultAttributedText.append(firstAttributed)

        let secondAttributed = NSAttributedString(string: " / " + secondPart, attributes: [.foregroundColor: UIColor(.foregroundSubtler)])
        resultAttributedText.append(secondAttributed)
        
        titleLabel.attributedText = resultAttributedText
    }
    
    
    func updateRandomProgress(progressVal: Float) {
        // progressView의 progress를 애니메이션과 함께 업데이트
        progressView.setProgress(progressVal, animated: true)
    }
    
    func showAnimatedGradientSkeleton(isPlaceholder: Bool) {
        if isPlaceholder {
            showAnimatedGradientSkeleton()
        } else {
            hideSkeleton()
        }
    }
    
    /// current/total 을 0...1 로 정규화 (1화=0, 마지막화=1)
    func episodeProgress(current: Int?, total: Int?) -> Float {
        guard let total = total, total >= 1,
              let current = current else { return 0 }
        if total == 1 { return 0 }                  // 단 1화만 있으면 0%
        let c = min(max(current, 1), total)         // 1...total 로 클램프
        return Float(c - 1) / Float(total - 1)
    }
}
