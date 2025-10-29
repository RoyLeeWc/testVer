//
//  HomeViewController.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/5/25.
//

import UIKit
import SnapKit
import SwinjectStoryboard
import Combine
import SkeletonView

final class HomeViewController: UIViewController, HomeRootNavigationBarPresentable {
    
    private var viewModel: HomeViewModel!
    
    var rootNavigationBar = HomeRootNavigationBar()
    
    private var skeletonOverlay: LZSnackSkeletonView?
    
    private var sections: [HomeSection] = [ ]
    
    //private var previousScrollOffset: CGFloat = 0
    private var isRootNavigationBarHidden = false
    
    private var mainBannerAutoScrollTimer: Timer?
    private var originalAutoScrollTimer: Timer?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    private var subscriptions = Set<AnyCancellable>()
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<HomeSection, HomeSectionEntity>!
    
    private var mainFooterView: UICollectionReusableView?
    
    // 섹션별 아이템 배열 관리
    var sectionItems: [HomeSection: [HomeSectionEntity]] = [:]
    var verticalLoading = false
    
    init?(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
        fetchData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func setupUI() {
        
        view.backgroundColor = UIColor(.backgroundDefault)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.delegate = self
        
        collectionView.contentInsetAdjustmentBehavior = .never
        
        // 셀 및 헤더 등록
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        collectionView.register(MainBannerCell.self)
        collectionView.register(MainBannerFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter)
        
        
        collectionView.register(RankingCell.self)
        collectionView.register(RankingHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        
        collectionView.register(WatchHistoryCell.self)
        collectionView.register(WatchHistoryHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        
        collectionView.register(OriginalCell.self)
        collectionView.register(OriginalHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        
        collectionView.register(GenreCell.self)
        collectionView.register(GenreHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        
        collectionView.register(AllContentsCell.self)
        collectionView.register(AllContentsHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        

        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        collectionView.isSkeletonable = true
        collectionView.backgroundColor = UIColor(.backgroundDefault)

        setupRootNavigationBar()
        rootNavigationBar.delegate = self
        
        configureDataSource()
        
        collectionView.addSafeAreaOffsetPullToRefresh { [weak self] in
            guard let self else { return }
            var snapshot = dataSource.snapshot()
            snapshot.deleteAllItems()
            self.dataSource.apply(snapshot, animatingDifferences: true)
            self.viewModel.fetchSectionList()
        }
        
    }
    
    private func bind() {
        NotificationCenter.default.publisher(for: .LZSChangeLocaleStringNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
            }.store(in: &subscriptions)
        
        
        Publishers.MergeMany(
            NotificationCenter.default.publisher(for: .LZSMainBannerScrollDidBegin),
            NotificationCenter.default.publisher(for: .LZSOriginalScrollDidBegin)
        )
        .receive(on: RunLoop.main)
        .sink { [weak self] _ in self?.stopMainBannerAutoScroll() }
        .store(in: &subscriptions)
        
        Publishers.MergeMany(
            NotificationCenter.default.publisher(for: .LZSMainBannerScrollDidEnd),
            NotificationCenter.default.publisher(for: .LZSOriginalScrollDidEnd)
        )
        .receive(on: RunLoop.main)
        .sink { [weak self] _ in self?.startMainBannerAutoScroll() }
        .store(in: &subscriptions)
        
        
        viewModel.$sections
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] sections in
                guard let self else { return }
                self.sections = sections
                var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeSectionEntity>()
                for section in sections {
                    snapshot.appendSections([section])
                }
                dataSource.apply(snapshot, animatingDifferences: true) {
                    self.viewModel.fetchSectionsData(sections: sections)
                }
            }.store(in: &subscriptions)
        
        viewModel.$sectionsData
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] sectionData in
                guard let self else { return }
                updateSection(sectionData.section, with: sectionData.homeSectionEntityArray)
            }.store(in: &subscriptions)
    }
    
    
    private func fetchData() {
        collectionView.alpha = 0
        setSkeletonOverlay()
        onMainAfter(delay: 1) {
            self.viewModel.fetchSectionList()
        }
    }
    
    private func updateSection(_ section: HomeSection, with items: [HomeSectionEntity]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(items, toSection: section)
        if section.type == .mainBanner {
            dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
                self?.removeSkeletonOverlay()
                self?.collectionView.refreshControl?.endRefreshing()
            }
            
        } else {
            dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
                
            }
        }
    }
    
    // viewDidAppear에서 메인배너 섹션의 중간으로 스크롤하여 양쪽 무한 스크롤 느낌을 줌
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startMainBannerAutoScroll()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopMainBannerAutoScroll()
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            
            let section = self?.sections[sectionIndex]
            
            switch section?.type {
            case .mainBanner:
                return self?.makeMainBannerLayout()
            case .ranking:
                return self?.makeRankingLayout()
            case .watchHistory:
                return self?.makeWatchHistoryLayout()
            case .original:
                return self?.makeOriginalLayout()
            case .curation:
                return self?.makeGenreLayout()
            case .allContents:
                return self?.makeVerticalInfiniteLayout(using: layoutEnvironment)
            case .none:
                return self?.makeVerticalInfiniteLayout(using: layoutEnvironment)
            case .some(.serialize):
                return self?.makeVerticalInfiniteLayout(using: layoutEnvironment)
            }
        }
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<HomeSection, HomeSectionEntity>(collectionView: collectionView) {
            [weak self] collectionView, indexPath, item in
            return self?.configureCell(collectionView: collectionView, indexPath: indexPath, element: item)
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                
                let section = self?.sections[indexPath.section]

                switch section?.type {
                case .mainBanner: break
                case .ranking:
                    guard let headerView = collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: RankingHeaderView.reuseIdentifier,
                        for: indexPath) as? RankingHeaderView else {
                        return UICollectionReusableView()
                    }
                    return headerView
                case .watchHistory:
                    guard let headerView = collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: WatchHistoryHeaderView.reuseIdentifier,
                        for: indexPath) as? WatchHistoryHeaderView else {
                        return UICollectionReusableView()
                    }
                    headerView.delegate = self
                    return headerView
                case .original:
                    guard let headerView = collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: OriginalHeaderView.reuseIdentifier,
                        for: indexPath) as? OriginalHeaderView else {
                        return UICollectionReusableView()
                    }
                    return headerView
                case .curation:
                    guard let headerView = collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: GenreHeaderView.reuseIdentifier,
                        for: indexPath) as? GenreHeaderView else {
                        return UICollectionReusableView()
                    }
                    headerView.titleLabel.text = section?.headerTitle
                    return headerView
                case .allContents:
                    guard let headerView = collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: AllContentsHeaderView.reuseIdentifier,
                        for: indexPath) as? AllContentsHeaderView else {
                        return UICollectionReusableView()
                    }
                    headerView.titleLabel.text = section?.headerTitle
                    headerView.delegate = self
                    
                    return headerView
                case .none:
                    return UICollectionReusableView()
                case .serialize:
                    return UICollectionReusableView()
                }
                
            case UICollectionView.elementKindSectionFooter:
                // mainBanner 섹션에 대해서만 footer를 반환하고, 그 외에는 빈 뷰 반환
                let section = self?.sections[indexPath.section]
                if section?.type == .mainBanner {
                    guard let footerView = collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: MainBannerFooterView.reuseIdentifier,
                        for: indexPath) as? MainBannerFooterView else {
                        return UICollectionReusableView()
                    }
                    
                    footerView.updateCurrentIndex(0, totalPages: 5)
                    self?.mainFooterView = footerView
                    return footerView
                }
                
            default:
                return UICollectionReusableView()
            }
            
            return UICollectionReusableView()
        }
    }
    
    private func configureCell(collectionView: UICollectionView, indexPath: IndexPath, element: HomeSectionEntity) -> UICollectionViewCell {
        let section = self.sections[indexPath.section]
        
        switch section.type {
        case .mainBanner:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainBannerCell.reuseIdentifier, for: indexPath) as? MainBannerCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(element)
            return cell
            
        case .ranking:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RankingCell.reuseIdentifier, for: indexPath) as? RankingCell else {
                return UICollectionViewCell()
            }
            
            let rank = indexPath.item + 1
            cell.configure(element, rank: rank)
            return cell
            
        case .watchHistory:
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WatchHistoryCell.reuseIdentifier, for: indexPath) as? WatchHistoryCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(element)
            return cell
            
        case .original:
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OriginalCell.reuseIdentifier, for: indexPath) as? OriginalCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(element)
            cell.delegate = self
            return cell
            
        case .curation:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenreCell.reuseIdentifier, for: indexPath) as? GenreCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(element)
            return cell
            
        case .allContents:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AllContentsCell.reuseIdentifier, for: indexPath) as? AllContentsCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(element)
            return cell
        case .serialize:
            return UICollectionViewCell()
        }
    }
    
    private func setSkeletonOverlay() {
        guard skeletonOverlay == nil else { return }
        let overlay = LZSnackSkeletonView()
        overlay.isUserInteractionEnabled = false
        
        // view에 추가
        view.addSubview(overlay)
        // collectionView와 동일한 제약 설정
        overlay.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        skeletonOverlay = overlay
    }
    
    private func removeSkeletonOverlay() {
        guard let overlay = skeletonOverlay else { return }
        UIView.animate(withDuration: 0.25, animations: {
            overlay.alpha = 0
        }, completion: { _ in
            // ③ 뷰 계층에서 제거
            overlay.removeFromSuperview()
            self.skeletonOverlay = nil
            
            UIView.animate(withDuration: 0.15, animations: {
                self.collectionView.alpha = 1
            }, completion: { _ in
                
            })
        })
    }
    
    func loadMoreVerticalData() {
//        guard !verticalLoading else { return }
//        verticalLoading = true
//        let currentCount = self.sectionItems[.verticalInfinite]?.count ?? 0
//        var newItems: [CellItem] = []
//        for index in currentCount..<currentCount + 20 {
//            newItems.append(CellItem(title: "Vertical Item \(index)"))
//        }        
//        onMain {
//            if self.sectionItems[.verticalInfinite] != nil {
//                self.sectionItems[.verticalInfinite]?.append(contentsOf: newItems)
//            } else {
//                self.sectionItems[.verticalInfinite] = newItems
//            }
//            self.applySnapshot()
//            self.verticalLoading = false
//        }
    }
    
    
    // MARK: 레이아웃 생성함수 모음
    // 배너 레이아웃
    private func makeMainBannerLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        var mainBannerHeight = CGFloat(540)
        
        if UIDevice.isiPad {
            mainBannerHeight = 725
        }
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                 heightDimension: .estimated(mainBannerHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.orthogonalScrollingBehavior = .groupPagingCentered
        sectionLayout.interGroupSpacing = 10
        
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44)),
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
        
        sectionLayout.boundarySupplementaryItems = [sectionFooter]
        
        sectionLayout.visibleItemsInvalidationHandler = { [weak self] visibleItems, contentOffset, layoutEnvironment in
            let containerWidth = layoutEnvironment.container.effectiveContentSize.width
            let centerX = contentOffset.x + containerWidth / 2
            
            guard let centerItem = visibleItems.min(by: { abs($0.frame.midX - centerX) < abs($1.frame.midX - centerX) }) else {
                return
            }
            
            let currentCenterIndex = centerItem.indexPath.item
            let originalItemCount = 10
            let relativeIndex = currentCenterIndex % originalItemCount
            
            onMain {
                if let footer = self?.collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionFooter)
                    .first as? MainBannerFooterView {
                    footer.updateCurrentIndex(relativeIndex,totalPages: originalItemCount)
                }
            }
        }
        
        return sectionLayout
    }
    
    private var previousCenterIndex: Int?
    
    // 랭킹 레이아웃
    private func makeRankingLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0/3.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(300),
                                               heightDimension: .absolute(328))
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: 3
        )

        group.interItemSpacing = .fixed(20)
        
        // 3. 섹션: 위에서 정의한 그룹을 반복적으로 배치
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.orthogonalScrollingBehavior = .groupPaging
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
        sectionLayout.interGroupSpacing = 20
        
        // 4. 헤더 구성
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(64))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        
        // section의 좌우 inset(10)로 인해 헤더도 좌우에 동일한 여백이 생기므로 이를 보정
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -20, bottom: 0, trailing: -20)
        
        sectionLayout.boundarySupplementaryItems = [header]
        
        return sectionLayout
    }
    
    
    // 시청내역 레이아웃
    private func makeWatchHistoryLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(100),
                                               heightDimension: .absolute(172))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        
        
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.orthogonalScrollingBehavior = .continuous
        sectionLayout.interGroupSpacing = 8
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(56))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -20, bottom: 0, trailing: -20)
        
        sectionLayout.boundarySupplementaryItems = [header]
        return sectionLayout
    }
    
    
    // 오리지널 레이아웃
    private func makeOriginalLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(320),
                                               heightDimension: .absolute(480))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.orthogonalScrollingBehavior = .groupPaging
        sectionLayout.interGroupSpacing = 20
        
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(80))
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -20, bottom: 0, trailing: -20)
        
        sectionLayout.boundarySupplementaryItems = [header]
        return sectionLayout
    }
    
    // 장르 레이아웃
    private func makeGenreLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(100),
                                               heightDimension: .absolute(150))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.orthogonalScrollingBehavior = .continuous
        sectionLayout.interGroupSpacing = 8
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(56))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -20, bottom: 0, trailing: -20)
        
        sectionLayout.boundarySupplementaryItems = [header]
        return sectionLayout
    }
    
    private func makeVerticalInfiniteLayout(using layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        // 1. 기기에 따라 컬럼 수 결정
        let columns = UIDevice.isiPad ? 6 : 3
        
        // 2. 전체 콘텐츠 인셋 및 아이템 간격
        let sideInset: CGFloat = 20
        let interItemSpacing: CGFloat = 8
        let interGroupSpacing = interItemSpacing
        
        // 3. 컨테이너 너비에서 인셋·간격 제외한 실제 사용 가능 너비
        let totalSpacing = interItemSpacing * CGFloat(columns - 1)
            + sideInset * 2
        let containerWidth = layoutEnvironment.container.effectiveContentSize.width
        let availableWidth = containerWidth - totalSpacing
        
        // 4. 아이템 너비/높이 계산 (3:2 비율)
        let itemWidth  = availableWidth / CGFloat(columns)
        let itemHeight = itemWidth * (3.0 / 2.0)
        
        // 5. 아이템 & 그룹 정의
        let itemSize = NSCollectionLayoutSize(
            widthDimension:  .absolute(itemWidth),
            heightDimension: .absolute(itemHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension:  .fractionalWidth(1.0),
            heightDimension: .absolute(itemHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize:   groupSize,
            subitem:      item,
            count:        columns
        )
        group.interItemSpacing = .fixed(interItemSpacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top:    0,
            leading: sideInset,
            bottom: 20,
            trailing: sideInset
        )
        
        section.interGroupSpacing = interGroupSpacing

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(56)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -20, bottom: 0, trailing: -20)
        
        section.boundarySupplementaryItems = [header]


        return section
    }
}

extension HomeViewController: UICollectionViewDelegate {
    
    func startMainBannerAutoScroll(withOriginalAutoScroll: Bool = true ) {
//        mainBannerAutoScrollTimer?.invalidate()
//        mainBannerAutoScrollTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
//            self?.scrollToNextMainBannerItem()
//        }
//        
//        if withOriginalAutoScroll {
//            originalAutoScrollTimer?.invalidate()
//            originalAutoScrollTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
//                self?.scrollToNextOriginalItem()
//            }
//        }
    }

    func stopMainBannerAutoScroll(withOriginalAutoScroll: Bool = true ) {
        mainBannerAutoScrollTimer?.invalidate()
        mainBannerAutoScrollTimer = nil
        
        if withOriginalAutoScroll {
            originalAutoScrollTimer?.invalidate()
            originalAutoScrollTimer = nil
        }
    }

    
    func scrollToNextMainBannerItem() {
        // HomeSection 배열에서 메인 배너 섹션의 위치 찾기
        guard let mainBannerSectionIndex = sections.firstIndex(where: { $0.type == .mainBanner }) else { return }
        
        // 메인 배너 섹션에 속하는 현재 보이는 아이템의 인덱스들 필터링
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems.filter { $0.section == mainBannerSectionIndex }
        let sortedVisibleIndexPaths = visibleIndexPaths.sorted { $0.item < $1.item }
        
        // 현재 보이는 아이템 중 첫 번째 인덱스를 기준으로 다음 아이템 결정
        guard let currentIndexPath = sortedVisibleIndexPaths.first else { return }
        var nextItem = currentIndexPath.item + 1
        
        // 현재 메인 배너 섹션의 전체 아이템 개수 확인
        let currentItems = dataSource.snapshot().itemIdentifiers(inSection: sections[mainBannerSectionIndex])
        if nextItem >= currentItems.count {
            nextItem = 0  // 범위를 초과하면 첫 번째 아이템으로 순환
        }
        
        // 다음 아이템의 IndexPath 생성 후 스크롤
        let nextIndexPath = IndexPath(item: nextItem, section: mainBannerSectionIndex)
        collectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
    }
    
    func scrollToNextOriginalItem() {
        // 오리지날 섹션 인덱스 추출
        guard let mainBannerSectionIndex = sections.firstIndex(where: { $0.type == .original }) else { return }
        
        // 오리지날 섹션에 속하는 현재 보이는 아이템의 인덱스들 필터링
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems.filter { $0.section == mainBannerSectionIndex }
        let sortedVisibleIndexPaths = visibleIndexPaths.sorted { $0.item < $1.item }
        
        // 현재 보이는 아이템 중 첫 번째 인덱스를 기준으로 다음 아이템 결정
        guard let currentIndexPath = sortedVisibleIndexPaths.first else { return }
        var nextItem = currentIndexPath.item + 1
        
        // 현재 메인 배너 섹션의 전체 아이템 개수 확인
        let currentItems = dataSource.snapshot().itemIdentifiers(inSection: sections[mainBannerSectionIndex])
        if nextItem >= currentItems.count {
            nextItem = 0  // 범위를 초과하면 첫 번째 아이템으로 순환
        }
        
        // 다음 아이템의 IndexPath 생성 후 스크롤
        let nextIndexPath = IndexPath(item: nextItem, section: mainBannerSectionIndex)
        collectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        handleInfiniteScroll(of: scrollView)
        updateNavigationBarBackground(by: scrollView)
        startMainBannerAutoScroll()
    }

    // 스크롤 시작할대 자동 스크롤 종료
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopMainBannerAutoScroll()
    }

    // 스크롤 감속이 완료
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }

    // MARK: 무한 스크롤
    private func handleInfiniteScroll(of scrollView: UIScrollView) {
        let offsetY       = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight   = scrollView.frame.height
        
        guard offsetY > contentHeight - frameHeight - 100 else { return }
        loadMoreVerticalData()
    }

    // MARK: 네비게이션 바 배경 처리
    private func updateNavigationBarBackground(by scrollView: UIScrollView) {
        
        self.rootNavigationBar.applyGradientBackground()
        
//        let offsetY = scrollView.contentOffset.y
//        let topThreshold: CGFloat = 300
//
//        if offsetY <= topThreshold {
//            UIView.animate(withDuration: 0.3) {
//                self.rootNavigationBar.applyGradientBackground()   // 투명+그라디언트
//            }
//        } else {
//            UIView.animate(withDuration: 0.3) {
//                self.rootNavigationBar.applySolidBackground()      // 디폴트 배경
//            }
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let sectionType = sections[indexPath.section].type
        
        switch sectionType {
            
        case .mainBanner:
            break
        case .ranking:
            break
        case .watchHistory:
            break
        case .original:
            break
        case .curation:
            break
        case .allContents:
            break
        case .serialize:
            break
        }
    }
    
    
    func originalSectionItemSelect(indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath),
              let cell = collectionView.cellForItem(at: indexPath) as? OriginalCell else { return }
        
        if !cell.isAlreadyOpened {
            stopMainBannerAutoScroll()
            let toastView = LZSnackToastView(text: "\(item.title)의 알림 설정이 완료되었습니다.")
            LZSnackToastHelper.showOnce(on: view, toast: toastView, duration: 2.0)
        }
    }
    
    
}

extension HomeViewController: AllContentsHeaderViewDelegate, OriginalCellDelegate {
    
    
    func tappedBottomButton(isAlreadyOpened: Bool, title: String) {
        if !isAlreadyOpened {
            stopMainBannerAutoScroll()
            let toastView = LZSnackToastView(text: "\(title)의 알림 설정이 완료되었습니다.")
            LZSnackToastHelper.showOnce(on: view, toast: toastView, duration: 2.0)
        }
    }
    
    
    func allContentsHeaderViewDidTapSortButton(_ header: AllContentsHeaderView, anchor: UIView) {
        presentDropdownMenu(
            anchor: anchor,
            menuWidth: max(anchor.bounds.width, 120),
            current: AllContentsSortOption.like
        ) { [weak self] option in
            guard let self = self else { return }
            header.updateSortTitle(option)
            self.applySort(option)
        }
    }

    
    private func applySort(_ option: AllContentsSortOption) {
        switch option {
        case .like:  print("좋아요순 정렬")
        case .wish:  print("찜한순 정렬")
        case .share: print("공유순 정렬")
        }
        // 데이터 정렬 후 snapshot 갱신 …
    }
}


extension HomeViewController: HomeRootNavigationBarDelegate {
    
    func rootNavigationBarDidTapLogo(_ navigationBar: HomeRootNavigationBar) {
        
    }
    
    func rootNavigationBarDidTapSearch(_ navigationBar: HomeRootNavigationBar) {
        guard let vc = AppContext.container.resolve(SearchViewController.self) else { return }
        navigationController?.pushHidesBottomBarViewController(vc, animated: true)
    }
    
}

extension HomeViewController: WatchHistoryHeaderViewDelegate {
    
    func watchHistoryHeaderViewDidTapMore(_ watchHistoryHeaderView: WatchHistoryHeaderView) {
        if let controllers = tabBarController?.viewControllers,
           let targetNav = controllers[safe: 2] {
            tabBarController?.selectedViewController = targetNav
            // 변경 직후에 커스텀 UI 업데이트가 필요하다면
            (tabBarController as? TabBarViewController)?
                .updateTabSelectionAppearance()
        }
    }
    
}
