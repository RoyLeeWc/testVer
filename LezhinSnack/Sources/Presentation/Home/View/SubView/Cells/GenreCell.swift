//
//  GenreCell.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/17/25.
//

import UIKit
import SnapKit


final class GenreCell: UICollectionViewCell {
    
    private var marksStackView: LZSnackBadgeStackView?
    
    private var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor(.darkGray333)
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
        titleLabel.text = nil
        thumbnailImageView.image = nil
        marksStackView?.removeFromSuperview()
        marksStackView = nil
    }
    
    private func setupUI() {
        
        isSkeletonable = true
        
        contentView.addSubview(thumbnailImageView)
        thumbnailImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        thumbnailImageView.roundCorners(cornerRadius: 4)
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(thumbnailImageView.snp.bottom).offset(4)
        }
    }
    
    func configure(ongoing: ContentsOngoingItemEntity) {
        
        if let urlStr = ongoing.coverImagePath, let url = URL(string: urlStr) {
            thumbnailImageView.kf.setImage(with: url)
        } else {
            thumbnailImageView.image = nil
        }
        
        if let ts = ongoing.contentsOpenedAt,LZSUtil.EpisodePolicy.isOpenedWithin24Hours(epoch: ts) {
            let fullText = "새 에피소드 / \(ongoing.episodeAlias)화"
            setTitleLabelTextColor(fullText)
        }
      
        
        // 1) 서버 순서 유지 + MarkType 기준 중복 제거 + 최대 3개만 노출(원하면 숫자 변경)
        var seen = Set<MarkType>()
        let uiTypes: [LZSnackBadgeType] = ongoing.marks
            .filter { seen.insert($0.type).inserted }        // 중복 제거(순서 보존)
            .compactMap { LZSnackBadgeType(mark: $0) }        // MarkEntity -> UI 타입
            .prefix(3)                                        // <= 원하는 최대 개수
            .map { $0 }
        
        showAnimatedGradientSkeleton(isPlaceholder: false)
        
        guard !uiTypes.isEmpty else { return }
        
        // 새 스택뷰 추가
        let tagView = LZSnackBadgeStackView(types: uiTypes)
        thumbnailImageView.addSubview(tagView)
        tagView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.trailing.equalToSuperview().offset(-4)
            make.height.equalTo(16)
        }
        
        marksStackView = tagView
        
    }
    func configure(curation: ContentsCurationItemEntity) {
        let titleImagUrl = URL(string: curation.contentsDetail?.coverImagePath ?? "")
        thumbnailImageView.kf.setImage(with: titleImagUrl)
        showAnimatedGradientSkeleton(isPlaceholder: false)
    }
    
    func configure(ranking: ContentsRankingItemEntity) {
        let titleImagUrl = URL(string: ranking.contentsDetail?.coverImagePath ?? "")
        thumbnailImageView.kf.setImage(with: titleImagUrl)
        showAnimatedGradientSkeleton(isPlaceholder: false)
    }
 
    func configure(_ data: HomeSectionEntity) {
        showAnimatedGradientSkeleton(isPlaceholder: data.isPlaceholder)
    }
    
    func showAnimatedGradientSkeleton(isPlaceholder: Bool) {
        if isPlaceholder {
            showAnimatedGradientSkeleton()
        } else {
            hideSkeleton()
        }
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
        let firstPart = components[0]        // "에피소드"
        let secondPart = components[1]       // "episodeAlias화"

        let resultAttributedText = NSMutableAttributedString()
        

        let firstAttributed = NSAttributedString(string: firstPart, attributes:[.foregroundColor: UIColor(.foregroundSubtler)])
        resultAttributedText.append(firstAttributed)

        let secondAttributed = NSAttributedString(string: " " + secondPart, attributes: [.foregroundColor: UIColor(.foregroundBrand)])
        resultAttributedText.append(secondAttributed)

        titleLabel.attributedText = resultAttributedText
        
    }
}
