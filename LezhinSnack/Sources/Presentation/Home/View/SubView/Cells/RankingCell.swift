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
    
    private var rankMarkView: LZSnackMarkView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()  // 셀 내부 뷰들을 추가 및 제약조건 설정
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:)는 지원하지 않습니다. 코드 기반으로 구현해 주세요.")
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
        
        rankThumbnailImageView.roundCorners(cornerRadius: 4)
        
    }
    
    func configure(_ data: HomeSectionEntity, rank: Int) {
        
        resizeUILabelsHeight(data)
        
        let imageName = "rankNumber\(rank)"
        rankImageView.image = UIImage(named: imageName)
        
        if !data.isPlaceholder {
            if let rankMarkView = rankMarkView {    
                rankMarkView.removeFromSuperview()
                self.rankMarkView = nil
                makeRankMarkView()
            } else {
                makeRankMarkView()
            }
        }
        
        showAnimatedGradientSkeleton(isPlaceholder: data.isPlaceholder)
        
    }
    
    
    func resizeUILabelsHeight(_ data: HomeSectionEntity) {
        
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.minimumLineHeight = 22
//        paragraphStyle.maximumLineHeight = 22
//        
//        // NSAttributedString 생성. 폰트, 색상, paragraph style 적용
//        let attributedTitle = NSAttributedString(
//            //string: data.title+data.title+data.title+data.title+data.title+data.title+data.title+data.title,
//            string: data.title,
//            attributes: [
//                .font: UIFont.pretendardMedium(size: 16),
//                .foregroundColor: UIColor.white,
//                .paragraphStyle: paragraphStyle
//            ]
//        )
//        // rankTitleLabel에 attributedText 할당
//        rankTitleLabel.attributedText = attributedTitle
        
        rankTitleLabel.text = "2줄 초과시 말줄임 2줄 초과시 말줄임 2줄 초과시 말줄임 2줄 초과시 말줄임 2줄 초과시 말줄임 2줄 초과시 말줄임 2줄 초과시 말줄임 "
        
        let keywords = ["키워드1", "키워드2", "키워드3"]
        let keywordsString = keywords.joined(separator: " · ")
        
        rankKeywordLabel.text = keywordsString
        
        self.layoutIfNeeded()
        let newTitleSize = rankTitleLabel.sizeThatFits(CGSize(width: rankTitleLabel.frame.width, height: CGFloat.greatestFiniteMagnitude))
        
        let newKeywordSize = rankKeywordLabel.sizeThatFits(CGSize(width: rankKeywordLabel.frame.width, height: CGFloat.greatestFiniteMagnitude))
        
        // 저장된 제약조건을 업데이트
        self.rankTitleLabelHeightConstraint?.update(offset: newTitleSize.height)
        self.rankKeywordLabelHeightConstraint?.update(offset: newKeywordSize.height)
        
    }
    
    func makeRankMarkView() {
        rankMarkView = LZSnackMarkView(type: .allCases.randomElement()!)
        guard let rankMarkView else { return }
        rankContentContainerView.addSubview(rankMarkView)
        rankMarkView.snp.makeConstraints { make in
            make.top.equalTo(rankKeywordLabel.snp.bottom).offset(8)
            make.leading.equalTo(rankThumbnailImageView.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
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
