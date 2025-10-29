//
//  RankingCell.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/15/25.
//

import UIKit
import SnapKit
import SkeletonView
import Kingfisher

// Height 96
final class RankingCell: UICollectionViewCell {
    
    let rankView: UIView =  {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let rankImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let rankContentContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isSkeletonable = true
        return view
    }()
    
    let rankThumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor(.darkGray333)
        imageView.clipsToBounds = true
        imageView.isSkeletonable = true
        return imageView
    }()
    
    var rankTitleLabelHeightConstraint: Constraint?
    
    let rankTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendardMedium(size: 16)
        label.textColor = .white
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.isSkeletonable = true
        return label
    }()
    
    var rankKeywordLabelHeightConstraint: Constraint?
    
    let rankKeywordLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendardMedium(size: 13)
        label.textColor = UIColor(.whiteOpacity35)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.isSkeletonable = true
        return label
    }()
    private let markContainerView = UIView()
    private var rankMarkView: LZSnackMarkView?
    
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
        rankThumbnailImageView.image = nil
        self.rankMarkView = nil
        rankMarkView?.removeFromSuperview()
        markContainerView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLabelHeightsIfReady()
    }
    
    private func updateLabelHeightsIfReady() {
        // 가로폭이 아직 0이면 업데이트하지 않음
        let titleW = rankTitleLabel.bounds.width
        let keywordW = rankKeywordLabel.bounds.width
        guard titleW > 1, keywordW > 1 else { return }

        let tSize = rankTitleLabel.sizeThatFits(CGSize(width: titleW, height: .greatestFiniteMagnitude))
        let kSize = rankKeywordLabel.sizeThatFits(CGSize(width: keywordW, height: .greatestFiniteMagnitude))

        // 1pt 이상으로 보장
        rankTitleLabelHeightConstraint?.update(offset: max(ceil(tSize.height), 1))
        rankKeywordLabelHeightConstraint?.update(offset: max(ceil(kSize.height), 1))
    }
    
    private func setupUI() {
        // 좌측 랭크 컨테이너 뷰
        contentView.addSubview(rankView)
        rankView.snp.makeConstraints { make in
            make.width.equalTo(28)
            make.height.equalTo(60)
            make.top.leading.equalToSuperview()
        }
        
        // 랭킹 이미지 뷰
        rankView.addSubview(rankImageView)
        rankImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 랭크 컨텐츠 컨테이너 뷰
        contentView.addSubview(rankContentContainerView)
        rankContentContainerView.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalTo(rankView.snp.trailing)
        }
        
        // 랭크 컨텐츠 섬네일 이미지 뷰
        rankContentContainerView.addSubview(rankThumbnailImageView)
        rankThumbnailImageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalTo(64)
        }
        
        // 랭크 타이틀 라벨
        rankContentContainerView.addSubview(rankTitleLabel)
        rankTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(2)
            make.leading.equalTo(rankThumbnailImageView.snp.trailing).offset(8)
            self.rankTitleLabelHeightConstraint = make.height.equalTo(22).constraint
            make.trailing.equalToSuperview()
        }
        
        // 랭크 키워드 라벨
        rankContentContainerView.addSubview(rankKeywordLabel)
        rankKeywordLabel.snp.makeConstraints { make in
            make.top.equalTo(rankTitleLabel.snp.bottom)
            make.leading.equalTo(rankThumbnailImageView.snp.trailing).offset(8)
            self.rankKeywordLabelHeightConstraint = make.height.equalTo(18).constraint
            make.trailing.equalToSuperview()
        }
        
        // ⬇️ 키워드 라벨 아래에 마크 컨테이너 추가
        rankContentContainerView.addSubview(markContainerView)
        markContainerView.snp.makeConstraints { make in
            make.top.equalTo(rankKeywordLabel.snp.bottom).offset(8)
            make.leading.equalTo(rankThumbnailImageView.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualToSuperview().inset(8)
            make.height.equalTo(24)
//            make.bottom.lessThanOrEqualToSuperview().inset(8)
        }
        
        rankThumbnailImageView.roundCorners(cornerRadius: 4)
        
    }
    
    func configure(ranking: ContentsRankingItemEntity, rank: Int) {
        // TODO: rank 이미지/라벨 갱신
        // TODO: 썸네일: ranking.contentsDetail?.coverImagePath
        // TODO: 타이틀:  ranking.contentsDetail?.title ?? ranking.contentsAlias
        showAnimatedGradientSkeleton(isPlaceholder: false)
        
        let thumbnailImagePathUrl = URL(string: ranking.contentsDetail?.coverImagePath ?? "")
        rankThumbnailImageView.kf.setImage(with: thumbnailImagePathUrl)
        resizeUILabelsHeight(ranking)
        let imageName = "rankNumber\(rank)"
        rankImageView.image = UIImage(named: imageName)
        showAnimatedGradientSkeleton(isPlaceholder: false)
        
        if let type = ranking.badges
            .lazy
            .compactMap({ LZSnackMarkType(badge: $0) })
            .first {
            makeRankMarkView(type: type)
        } else {
            // 배지가 없거나 매핑 불가 마크 숨김
            rankMarkView = nil
        }
        
    }
    
    func configure(curation: ContentsCurationItemEntity, rank: Int) {
        // TODO: rank 이미지/라벨 갱신
        // TODO: 썸네일: ranking.contentsDetail?.coverImagePath
        // TODO: 타이틀:  ranking.contentsDetail?.title ?? ranking.contentsAlias
        showAnimatedGradientSkeleton(isPlaceholder: false)
        rankMarkView?.removeFromSuperview()
        rankMarkView = nil
        let thumbnailImagePathUrl = URL(string: curation.contentsDetail?.coverImagePath ?? "")
        rankThumbnailImageView.kf.setImage(with: thumbnailImagePathUrl)
        resizeUILabelsHeight(curation)
        let imageName = "rankNumber\(rank)"
        rankImageView.image = UIImage(named: imageName)
        showAnimatedGradientSkeleton(isPlaceholder: false)
        
        if let type = curation.badges
            .lazy
            .compactMap({ LZSnackMarkType(badge: $0) })
            .first {
            makeRankMarkView(type: type)
        } else {
            // 배지가 없거나 매핑 불가 마크 숨김
            rankMarkView = nil
        }
        
    }
    
    
    func configure(_ data: HomeSectionEntity) {
        showAnimatedGradientSkeleton(isPlaceholder: data.isPlaceholder)
    }
    
    func resizeUILabelsHeight(_ data: ContentsCurationItemEntity) {
        
        rankTitleLabel.text = data.contentsDetail?.title
        
        let keywords = data.contentsDetail?.keywordNames ?? []
        let keywordsString = keywords.joined(separator: " · ")
        
        rankKeywordLabel.text = keywordsString
        
        self.layoutIfNeeded()
        let newTitleSize = rankTitleLabel.sizeThatFits(CGSize(width: rankTitleLabel.frame.width, height: CGFloat.greatestFiniteMagnitude))
        
        let newKeywordSize = rankKeywordLabel.sizeThatFits(CGSize(width: rankKeywordLabel.frame.width, height: CGFloat.greatestFiniteMagnitude))
        
        // 저장된 제약조건을 업데이트
        self.rankTitleLabelHeightConstraint?.update(offset: newTitleSize.height)
        self.rankKeywordLabelHeightConstraint?.update(offset: newKeywordSize.height)
        
    }
    
    
    func resizeUILabelsHeight(_ data: ContentsRankingItemEntity) {
        
        rankTitleLabel.text = data.contentsDetail?.title
        
        let keywords = data.contentsDetail?.keywordNames ?? []
        let keywordsString = keywords.joined(separator: " · ")
        
        rankKeywordLabel.text = keywordsString
        
        self.layoutIfNeeded()
        let newTitleSize = rankTitleLabel.sizeThatFits(CGSize(width: rankTitleLabel.frame.width, height: CGFloat.greatestFiniteMagnitude))
        
        let newKeywordSize = rankKeywordLabel.sizeThatFits(CGSize(width: rankKeywordLabel.frame.width, height: CGFloat.greatestFiniteMagnitude))
        
        // 저장된 제약조건을 업데이트
        self.rankTitleLabelHeightConstraint?.update(offset: newTitleSize.height)
        self.rankKeywordLabelHeightConstraint?.update(offset: newKeywordSize.height)
        
    }
    
    func makeRankMarkView(type: LZSnackMarkType) {
        rankMarkView = LZSnackMarkView(type:type)
        guard let rankMarkView else { return }
        markContainerView.addSubview(rankMarkView)
        rankMarkView.snp.makeConstraints { make in
            make.edges.equalToSuperview()  // 컨테이너 한 칸짜리
        }
    }
    
    func showAnimatedGradientSkeleton(isPlaceholder: Bool) {
        if isPlaceholder {
            rankKeywordLabel.isHidden = true
            rankThumbnailImageView.showAnimatedGradientSkeleton()
            rankTitleLabel.showAnimatedGradientSkeleton()
        } else {
            rankKeywordLabel.isHidden = false
            rankThumbnailImageView.hideSkeleton()
            rankTitleLabel.hideSkeleton()
        }
    }
    
}
