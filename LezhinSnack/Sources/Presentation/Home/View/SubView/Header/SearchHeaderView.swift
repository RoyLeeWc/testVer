//
//  SearchHeaderView.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/26/25.
//

// Height 188

import UIKit
import SnapKit
import TTGTags


protocol SearchHeaderViewDelegate: AnyObject {
    func recentSearchDeleteAllTapped(_ searchHeaderView: SearchHeaderView)
    func recentSearchDeleteKeyword(_ searchHeaderView: SearchHeaderView, keyword: String)
    func searchSelectedKeyword(_ searchHeaderView: SearchHeaderView, keyword: String)
}


final class SearchHeaderView: UICollectionReusableView {
    
    let tagsTwoLineHeight: CGFloat = 66 // 30 + 30 + 5
    
    private var isExpanded = false
    
    weak var delegate: SearchHeaderViewDelegate?
    
    // 최근 검색어 태그뷰
    private let recentSearchTagContainerView: UIView = {
        UIView()
    }()
    
    private let recentSearchTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardBold(size: 16)
        label.textColor = .white
        label.numberOfLines = 0
        
        return label
    }()
    
    
    private var recentSearchTitles: [String] = []
    
    private lazy var recentCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        layout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.register(RecentSearchTagCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private let recentSearchTagBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(.borderDefault)
        return view
    }()
    
    
    private let recentDeleteAllButton: UIButton = {
        let button = UIButton(type: .system)
        let icon = UIImage(named: "ic_delete_gray")?.withRenderingMode(.alwaysOriginal)
        button.setImage(icon, for: .normal)
        button.setTitle("편집_모두_지우기".localized, for: .normal)
        button.setTitleColor(UIColor(.foregroundSubtler), for: .normal)
        button.titleLabel?.font = .pretendardMedium(size: 13)

        // 이미지-타이틀 간격 2pt, 나머지는 0
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        return button
    }()
    
    
    // 추천키워드 테그뷰
    private let recommendedTagContainerView: UIView = {
       UIView()
    }()
    
    private let recommendedTagTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardBold(size: 16)
        label.textColor = .white
        label.numberOfLines = 0
        
        return label
    }()
    
    private var recommendedTagView: LZSnackSearchTagContainerView = {
        let view = LZSnackSearchTagContainerView()
        return view
    }()
    
    private let recommendedMoreButton: UIButton = {
        let button = UIButton(type: .system)
        let icon = UIImage(named: "ic_chevron_down")?.withRenderingMode(.alwaysOriginal)
        button.setImage(icon, for: .normal)
        button.setTitle("더보기", for: .normal)
        button.setTitleColor(UIColor(.foregroundSubtler), for: .normal)
        button.titleLabel?.font = .pretendardMedium(size: 13)

        // 이미지-타이틀 간격 2pt, 나머지는 0
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        return button
    }()
    
    private let recommendedTagBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(.borderDefault)
        return view
    }()
    
    private let popularTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardSemiBold(size: 16)
        label.textColor = .white
        
        return label
    }()
    
    private var tagViewHeightConstraint: Constraint!
    private var recommendedMoreButtonHeightConstraint: Constraint!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setupRecentSearchTagView()
        setupRecommendedTagView()
        
    }
    
    
    private func setupRecentSearchTagView() {
        self.addSubview(recentSearchTagContainerView)
        recentSearchTagContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(91)
        }
        
        recentSearchTagContainerView.addSubview(recentSearchTitleLabel)
        recentSearchTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.height.equalTo(22)
        }
        
        recentSearchTitleLabel.text = "최근 검색어"
        
        recentSearchTagContainerView.addSubview(recentCollectionView)
        recentCollectionView.snp.makeConstraints { make in
            make.top.equalTo(recentSearchTitleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
        }
        
        recentSearchTagContainerView.addSubview(recentSearchTagBorderView)
        recentSearchTagBorderView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(recentCollectionView.snp.bottom).offset(16)
            make.bottom.equalToSuperview()
        }
        
        
        recentSearchTagContainerView.addSubview(recentDeleteAllButton)
        recentDeleteAllButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(recentSearchTitleLabel)
        }
        
        recentDeleteAllButton.addTarget(self, action: #selector(recentDeleteAllButtonTapped), for: .touchUpInside)
    }
    
    @objc private func recentDeleteAllButtonTapped() {
        delegate?.recentSearchDeleteAllTapped(self)
    }
    
    private func setupRecommendedTagView() {
        self.addSubview(recommendedTagContainerView)
        
        recommendedTagContainerView.snp.makeConstraints { make in
            make.top.equalTo(recentSearchTagContainerView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16) // 하단 여백 추가 - 중요!
        }
        
        recommendedTagContainerView.addSubview(recommendedTagTitleLabel)
        recommendedTagTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
        }
        
        recommendedTagTitleLabel.text = "추천 키워드"
        
        recommendedTagContainerView.addSubview(recommendedTagView)
        recommendedTagView.snp.makeConstraints { make in
            make.top.equalTo(recommendedTagTitleLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            tagViewHeightConstraint = make.height.equalTo(tagsTwoLineHeight)
                .priority(.high)    // .required(1000)가 아닌 .high(750)로
                .constraint
        }
        
        recommendedTagContainerView.addSubview(recommendedMoreButton)
        recommendedMoreButton.snp.makeConstraints { make in
            make.top.equalTo(recommendedTagView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            recommendedMoreButtonHeightConstraint = make.height.equalTo(18)
                .priority(.high)
                .constraint
        }
        
        recommendedTagContainerView.addSubview(recommendedTagBorderView)
        recommendedTagBorderView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(recommendedMoreButton.snp.bottom).offset(16) // bottom 대신 top 사용
        }
        
        recommendedTagContainerView.addSubview(popularTitleLabel)
        popularTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(recommendedTagBorderView.snp.bottom).offset(24)
            make.leading.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        popularTitleLabel.text = "실시간 인기 검색 작품"
        
        recommendedTagView.tagCollectionView.delegate = self
        recommendedTagView.tagCollectionView.scrollView.isScrollEnabled = false
        
        recommendedTagView.applySearchTagTitles(["선결혼 후연애", "로판", "BL", "불륜", "첫사랑", "현대판타지","선결혼 후연애", "로판", "선결혼 후연애", "로판", "BL", "불륜", "첫사랑", "현대판타지","선결혼 후연애", "로판", "BL", "불륜", "첫사랑", "현대판타지","선결혼 후연애", "로판", "BL", "불륜", "첫사랑", "현대판타지", "BL", "불륜", "첫사랑", "현대판타지","선결혼 후연애", "로판", "BL", "불륜", "첫사랑", "현대판타지"])
        
        recommendedMoreButton.addTarget(self, action: #selector(recommendedMoreButtonTapped), for: .touchUpInside)
    }
    
    @objc private func recommendedMoreButtonTapped() {
        // 1. 상태 토글
        isExpanded.toggle()
        
        // 2. 새 높이 계산
        let contentH = recommendedTagView.tagCollectionView.contentSize.height
        let newHeight = isExpanded
            ? max(tagsTwoLineHeight, contentH)   // 펼치기: 실제 콘텐츠 높이
            : tagsTwoLineHeight                // 접기: 2줄 높이 고정
        
        // 3. 제약 업데이트
        tagViewHeightConstraint.update(offset: newHeight)
        
        // 4. 버튼 타이틀 변경
        let title = isExpanded ? "접기" : "더보기"
        recommendedMoreButton.setTitle(title, for: .normal)
        
        let image = isExpanded ? UIImage(named: "ic_chevron_up")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "ic_chevron_down")?.withRenderingMode(.alwaysOriginal)
        recommendedMoreButton.setImage(image, for: .normal)
        
        self.layoutIfNeeded()
        self.invalidateCollectionViewLayout()
    }
    
}


extension SearchHeaderView: TTGTextTagCollectionViewDelegate {
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        // 현재 제약조건을 기반으로 레이아웃 계산
        setNeedsLayout()
        layoutIfNeeded()
        
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: UIView.layoutFittingCompressedSize.height)
        let preferredSize = systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        // 최소 높이 보장
        let finalHeight = max(preferredSize.height, 20)
        layoutAttributes.frame.size.height = finalHeight
        
        return layoutAttributes
    }
    
    func textTagCollectionView(_ tagView: TTGTextTagCollectionView!,
                               updateContentSize contentSize: CGSize) {
        // 최소 높이와 비교
        let newHeight = max(tagsTwoLineHeight, contentSize.height)
        print("Tag content size changed to: \(contentSize), new height: \(newHeight)")
        
        if contentSize.height > tagsTwoLineHeight + 10 {
            recommendedMoreButtonHeightConstraint.update(offset: 18)
            recommendedMoreButton.isHidden = false
        } else {
            recommendedMoreButtonHeightConstraint.update(offset: 0)
            recommendedMoreButton.isHidden = true
        }
        
        self.layoutIfNeeded()
        self.invalidateCollectionViewLayout()
    }
    
    private func invalidateCollectionViewLayout() {
        // 상위 뷰 계층을 탐색하여 UICollectionView 찾기
        var currentView: UIView? = self.superview
        while currentView != nil {
            if let collectionView = currentView as? UICollectionView {
                onMain {
                    collectionView.collectionViewLayout.invalidateLayout()
                }
                break
            }
            currentView = currentView?.superview
        }
    }
    
    func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, didTap tag: TTGTextTag!, at index: UInt) {
        guard tag.selected else { return }
        if let content = tag.content as? TTGTextTagStringContent {
            let keyword = content.text
            delegate?.searchSelectedKeyword(self, keyword: keyword)
        }
    }
}


extension SearchHeaderView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func configure(recent: [String]) {
      self.recentSearchTitles = recent
      recentCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recentSearchTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RecentSearchTagCell.reuseIdentifier,
            for: indexPath) as? RecentSearchTagCell else { return UICollectionViewCell()}
        let text = recentSearchTitles[indexPath.item]
        cell.configure(text: text)
        cell.delegate = self
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = recentSearchTitles[indexPath.item]
        let font = UIFont.pretendardSemiBold(size: 13)
        let textWidth = (text as NSString).size(withAttributes: [.font: font]).width
        let width = ceil(10 + textWidth + 2 + 16 + 8)
        return CGSize(width: width, height:  30)
    }
}

// MARK: - TagCellDelegate
extension SearchHeaderView: TagCellDelegate {
    
    func tagCellDidTapClose(keyword: String?) {
        guard let keyword = keyword else { return }
        self.delegate?.recentSearchDeleteKeyword(self, keyword: keyword)
    }
    
    func tagCellDidTapSearch(keyword: String?) {
        guard let keyword = keyword else { return }
        self.delegate?.searchSelectedKeyword(self, keyword: keyword)
    }
}
