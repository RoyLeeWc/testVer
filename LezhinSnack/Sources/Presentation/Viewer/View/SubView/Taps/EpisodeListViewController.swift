//
//  EpisodeListViewController.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/30/25.
//
import UIKit
import SnapKit
import EasyTipView
import Combine


final class EpisodeListViewController: UIViewController {
    
    enum Section {
        case main
    }
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, EpisodeListEntity>!
    private var subscriptions = Set<AnyCancellable>()
    
    private var isAlreadyShowTooltip: Bool = false
    
    private var initialSelectedIndex: Int?
    
    // 헤더 타이틀 캐시 (“N화~N화(완결)”)
    private var headerTitleText: String = ""
    
    // ⬇️ 상세 엔티티 보관(헤더 문구 계산에만 사용)
    private var contents: DisplayContentsDetailEntity?
    
    // 최하단 그라디언트 뷰
    private let gradientView: UIView = {
        let view = UIView()
        view.isHidden = true                // 기본적으로 숨김. scrollable 시 보여줌
        view.backgroundColor = .clear        // 배경 투명
        return view
    }()
    
    
    private lazy var tooltipPreferences: EasyTipView.Preferences = {
        var preferences = EasyTipView.globalPreferences
        preferences.positioning.bubbleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 0)
        preferences.positioning.contentInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        
        return preferences
    }()
    
    
    private let columnCount = 5.0
    
    let viewModel: EpisodeListViewModel
    
    init(viewModel: EpisodeListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupUI()
        bind()
        fetchData()
    }
    
    private func currentUnixSeconds() -> Int64 {
        Int64(Date().timeIntervalSince1970)
    }
    
    func isEarlyAccess(isPreview: Bool, previewOpenedAt: Int64?) -> Bool {
        guard isPreview, let t = previewOpenedAt, t > 0 else { return false }
        return t > currentUnixSeconds()
    }
    
    // 실데이터 → 셀에서 쓰는 얇은 뷰모델로 변환 + 스냅샷 적용
    func prefill(from episodes: [ContentsEpisodeEntity], contents: DisplayContentsDetailEntity, purchasedEpisodeIds: Set<String> = []) {
        self.contents = contents
        // 1) 회차index 만들기 (alias → Int)
        let mapped: [EpisodeListEntity] = episodes.map { ep in
            let episodeID = ep.episodeId
            let idx = Int(ep.alias) ?? 0
            // (A) 얼리 여부: isPreview && previewOpenedAt가 현재 이후
            let isEarly = isEarlyAccess(isPreview: ep.isPreview, previewOpenedAt: ep.previewOpenedAt)
            // (B) 구매여부 추가로 판별후 잠금해제
            let purchased = purchasedEpisodeIds.contains(ep.episodeId)
            // (C) 잠금: 무료가 아니고 & 미구매면 잠금  // 멤버십 추후 반영
            let locked = (!ep.isFree) && (!purchased)

            return EpisodeListEntity(
                contentsID: contents.id,
                episodeID: ep.episodeId,
                episodeIndex: idx,
                isLocked: locked,
                isEarlyAccess: isEarly,
                contentsAlias: contents.alias,
                episodeAlias: ep.alias,
                isFirstEarlyAccess: false
                
            )
        }
        // 2) 가장 빠른 얼리액세스 하나에만 툴팁 플래그
        var uiList = mapped
        if let firstEA = uiList.filter(\.isEarlyAccess).map(\.episodeIndex).min() {
            uiList = uiList.map { var episodeList = $0; episodeList.isFirstEarlyAccess = ($0.episodeIndex == firstEA); return episodeList }
        }
        
        // 3) 헤더 문구 미리 계산 (최초 1회 세팅)
        let nums = episodes.compactMap { Int($0.alias) }
        let minIdx = nums.min() ?? 1
        let maxIdx = nums.max() ?? 1
        let fin = (contents.isComplete == true) ? "(완결)" : ""
        headerTitleText = "\(minIdx)화~\(maxIdx)화\(fin)"
        
        // 4) 스냅샷 적용(메인큐)
        applySnapshot(items: uiList)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // ① 컬렉션뷰가 충분히 길어서 스크롤 가능한지 확인
        let isScrollable = collectionView.contentSize.height > collectionView.bounds.height
        gradientView.isHidden = !isScrollable
        
        // ② 그래디언트 레이어 프레임 업데이트
        gradientView.layer.sublayers?.forEach { layer in
            if let grad = layer as? CAGradientLayer {
                grad.frame = gradientView.bounds
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(.backgroundRaisedDefault)
        configureCollectionView()
        configureDataSource()
        configureGradientView()
    }
    
    
    private func bind() {
        viewModel.$episodeList
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] episodeList in
                self?.applySnapshot(items: episodeList)
            }
            .store(in: &subscriptions)
        
        viewModel.$episodeDetailList
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] episodeDetailList in
                
                NotificationCenter.default.post(
                    name: .LZSPurchaseEpisodeReceiveNotification,
                    object: episodeDetailList.possessionCoin // Int
                )
            }
            .store(in: &subscriptions)
    }
    
    /// ✅ ContentSelection에서 현재 회차 인덱스만 먼저 전달
    func setInitialSelectedIndex(_ index: Int) {
        initialSelectedIndex = index
        if isViewLoaded { selectInitialItemIfNeeded() }
    }
    
    private func selectInitialItemIfNeeded() {
        guard let idx = initialSelectedIndex else { return }
        let total = dataSource.snapshot().numberOfItems
        guard total > 0 else { return }
        
        // 범위 보정
        let clamped = max(0, min(idx, total - 1))
        let indexPath = IndexPath(item: clamped, section: 0)
        
        // 혹시 기존 선택이 남아있으면 정리
        (collectionView.indexPathsForSelectedItems ?? []).forEach {
            collectionView.deselectItem(at: $0, animated: false)
        }
        
        // 선택 적용 → isSelected 트리거 → 로띠 실행
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        
        // 화면에 안 보이면 한 번만 스크롤
        if !collectionView.indexPathsForVisibleItems.contains(indexPath) {
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        }
    }
    
    private func fetchData() {
        
//        viewModel.fetchEpisodes()
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsSelection = true
        collectionView.backgroundColor = UIColor(.clear)
        // 커스텀 셀 등록
        
        collectionView.register(EpisodeListCell.self)
        collectionView.register(ContentsListHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.snp.bottom)
        }
        
        collectionView.delegate = self
        collectionView.addPullToRefresh { [weak self] in
            var emptySnap = NSDiffableDataSourceSnapshot<Section, EpisodeListEntity>()
            emptySnap.appendSections([.main])
            // items 없이 섹션만 세팅 → 이전 아이템 모두 제거됨
            self?.dataSource.apply(emptySnap, animatingDifferences: true) { [weak self] in
                self?.isAlreadyShowTooltip = false
                self?.fetchData()
            }
        }
    }
    
    private func configureGradientView() {
        view.addSubview(gradientView)
        gradientView.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalToSuperview()
            make.height.equalTo(48)  // 높이 48pt 고정
        }
        
        // CAGradientLayer 생성하여 gradientView에 추가
        let gradLayer = CAGradientLayer()
        let baseColor = UIColor.init(hexString: "0A0B0E")
        gradLayer.colors = [
            baseColor.withAlphaComponent(0.0).cgColor,
            baseColor.withAlphaComponent(1.0).cgColor,
        ]
        gradLayer.locations = [0.0, 1.0]
        gradLayer.startPoint = CGPoint(x: 0.5, y: 0.0)  // 위쪽 중앙
        gradLayer.endPoint = CGPoint(x: 0.5, y: 1.0)    // 아래쪽 중앙
        gradientView.layer.addSublayer(gradLayer)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let spacing: CGFloat = 8
        
        // 1) 아이템 크기: 가로 1/5, 세로 그룹의 100%
        let itemSize = NSCollectionLayoutSize( widthDimension: .fractionalWidth(1.0 / columnCount),
                                               heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // 2) 그룹 크기: 가로 전체, 세로 96pt
        let groupSize = NSCollectionLayoutSize( widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(44))
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 5)
        // 아이템 사이 간격
        group.interItemSpacing = .fixed(spacing)
        
        // 3) 섹션: 그룹(행) 간격 설정
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        
        // (선택) 섹션 양쪽에 여백을 주고 싶으면 contentInsets 추가
        section.contentInsets = NSDirectionalEdgeInsets( top: 0, leading: 16, bottom: 0, trailing: 16 )
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(64))
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        
        section.boundarySupplementaryItems = [header]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    
    private func applySnapshot(items: [EpisodeListEntity]) {
        collectionView.refreshControl?.endRefreshing()
        var snapshot = NSDiffableDataSourceSnapshot<Section, EpisodeListEntity>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            guard let self = self else { return }
            // 스냅샷 적용 직후 contentSize 재확인
            self.collectionView.layoutIfNeeded()
            let isScrollable = self.collectionView.contentSize.height > self.collectionView.bounds.height
            self.gradientView.isHidden = !isScrollable
            // ✅ 데이터가 들어온 직후 현재 회차로 스크롤
            self.selectInitialItemIfNeeded()
        }
    }
    
    private func configureDataSource() {
        // Diffable Data Source 설정: 커스텀 셀 사용
        dataSource = UICollectionViewDiffableDataSource<Section, EpisodeListEntity>(collectionView: collectionView) { [weak self] collectionView, indexPath, item -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EpisodeListCell.reuseIdentifier, for: indexPath) as? EpisodeListCell else { return nil }
            
            cell.delegate = self
            cell.configure(with: item)
            
            return cell
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: ContentsListHeader.reuseIdentifier,
                for: indexPath) as? ContentsListHeader else {
                return UICollectionReusableView()
            }
            headerView.headerTitle.text = self?.headerTitleText.isEmpty == false ? self!.headerTitleText : "회차"
            return headerView
        }
    }
}


extension EpisodeListViewController: UICollectionViewDelegate, EpisodeListCellDelegate {
    
    func episodeListCellDidRequestTooltip(_ cell: EpisodeListCell) {
        //화면에 떠 있는 툴팁이 있으면 그냥 리턴
        if collectionView.subviews.contains(where: { $0 is EasyTipView }) { return}
        if isAlreadyShowTooltip { return }
        
        // 1. 셀의 indexPath 가져오기
        let totalItems = dataSource.snapshot().itemIdentifiers.count
        
        // 2. 몇 번째 컬럼인지 계산
        let itemIndex     = totalItems
        let itemsPerRow   = Int(columnCount)
        let columnIndex   = itemIndex % itemsPerRow
        
        // 3. 컬럼에 따라 bubbleInsets 조정
        if columnIndex < 2 {
          tooltipPreferences.positioning.bubbleInsets =
            UIEdgeInsets(top: 0, left: 50, bottom: 3, right: 0)
        } else {
          tooltipPreferences.positioning.bubbleInsets =
            UIEdgeInsets(top: 0, left: 0, bottom: 3, right: 0)
        }
        
        onMainAfter(delay: 0.01) { [weak self] in
            guard let self else { return }
            EasyTipView.show(
              forView: cell.timeIconImageView,
              withinSuperview: collectionView,
              text: "지금 구매하고 먼저 만나보세요.",
              preferences: tooltipPreferences,
              delegate: self
            )
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? EpisodeListCell else { return }
        // 2) 데이터 소스에서 해당 아이디(엔티티) 꺼내기
        guard let entity = dataSource.itemIdentifier(for: indexPath) else { return }
        
        // 이제 cell.configure(with:)에 쓴 것처럼 entity를 가지고 원하는 작업 가능
        print("선택된 에피소드:", entity.episodeIndex, "잠금:", entity.isLocked)
        
        if entity.isLocked {
            viewModel.fetchEpisodeDetails(contentsAlias: entity.contentsAlias, episodeAlias: entity.episodeAlias)
//            NotificationCenter.default.post(name: .LZSPurchaseEpisodeReceiveNotification, object: nil)
        } else {
//            NotificationCenter.default.post(name: .LZSEarlyAccessReceiveNotification, object: nil)
            // ✅ alias(표기 숫자)가 아니라, 실제 스크롤에 쓰일 0-based 인덱스를 보낸다
//            NotificationCenter.default.post(name: .LZSChangeEpisodeReceiveNotification, object: indexPath.item)
            
            //            NotificationCenter.default.post(name: .LZSChangeEpisodeReceiveNotification, object: entity.episodeIndex)
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        // 이미 선택된 아이템이 있다면 false 반환
//        if let selected = collectionView.indexPathsForSelectedItems,
//           !selected.isEmpty {
//            return false
//        }
//        return true
//    }
//
//    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
//        // 선택 해제는 항상 허용
//        return true
//    }
    
}


extension EpisodeListViewController: UIPopoverPresentationControllerDelegate, EasyTipViewDelegate {
    func easyTipViewDidTap(_ tipView: EasyTipView) {
        
    }
    
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        isAlreadyShowTooltip = true
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
    
    
}
