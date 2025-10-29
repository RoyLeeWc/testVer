//
//  AllContentCell.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/17/25.
//

import UIKit
import SnapKit

final class AllContentsCell: UICollectionViewCell {
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor(.darkGray333)
        return imageView
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
        thumbnailImageView.image = nil
    }
    
    private func setupUI() {
        
        isSkeletonable = true
        
        contentView.addSubview(thumbnailImageView)
        thumbnailImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        thumbnailImageView.roundCorners(cornerRadius: 4)
        
    }
    
    func configure(ongoing: ContentsOngoingItemEntity) {
        let titleImagUrl = URL(string: ongoing.coverImagePath ?? "")
        thumbnailImageView.kf.setImage(with: titleImagUrl)
        showAnimatedGradientSkeleton(isPlaceholder: false)
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
    
}
