//
//  WishListViewController.swift
//  LezhinSnack
//
//  Created by 신진우 on 4/20/25.
//

import UIKit
import SnapKit
import Combine


final class WishListViewController: UIViewController {
    
    enum Section {
        case wish
    }
    
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, WishContentItemEntity>!
    private var overlayEditView: UIView?
    
    private var floatingActionButton: UIButton = {
        let floatingActionButton = UIButton(type: .system)
        floatingActionButton.setTitle("편집_N개_삭제".localized(with: 0), for: .normal)
        floatingActionButton.titleLabel?.font = .pretendardSemiBold(size: 16)
        floatingActionButton.backgroundColor = UIColor(.fillDisabled)
        floatingActionButton.tintColor = UIColor(.foregroundDisabled)
        floatingActionButton.layer.cornerRadius = 6
        
        floatingActionButton.isHidden = true
        
        return floatingActionButton
    }()
    
    private let emptyContentsLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 14)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private var totalCheckBox: LZSnackCheckBox?
    
    
    private var isEditingMode = false {
        didSet {
            // 화면에 보이는 셀 모두에 편집 모드 플래그 전달
            collectionView.visibleCells
                .compactMap { $0 as? WishCell }
                .forEach { $0.isEditingMode = isEditingMode }
            
            collectionView.allowsSelection = isEditingMode
            collectionView.allowsMultipleSelection = isEditingMode
            
            var snapshot = dataSource.snapshot()
            
            // 2) 재구성할 아이템 식별자 배열: 전체를 재구성하려면 itemIdentifiers 사용
            let allItems = snapshot.itemIdentifiers(inSection: .wish)
            snapshot.reconfigureItems(allItems)
            
            // 3) 스냅샷 재적용 (animatingDifferences: false = 레이아웃만 업데이트)
            dataSource.apply(snapshot, animatingDifferences: false)
            
            
            isEditingMode ? showOverlayView() : hideOverlayView()
            floatingActionButton.isHidden = !isEditingMode
            
            if isEditingMode {
                viewModel.enterEditMode()
                // 데이터가 바뀐 뒤 한 프레임 후 선택/체크박스/버튼 초기화
                DispatchQueue.main.async { [weak self] in
                    self?.clearSelectionsAndUI()
                }
            } else {
                clearSelectionsAndUI()
                viewModel.exitEditMode()
            }
        }
    }
    
    var items: [WishContentItemEntity] = []
    
    let viewModel: WishListViewModel
    
    var subscriptions = Set<AnyCancellable>()
    
    init(viewModel: WishListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(.backgroundDefault)
        setupUI()
        initializeEmptySnapshot()
        bind()
        fetchData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isEditingMode { isEditingMode = false }
    }
    
    private func setupUI() {
        configureCollectionView()
        configureFloatingButton()
        configureEmptyContentLabel()
        configureDataSource()
    }
    
    private func bind() {
        viewModel.$items
            .receive(on: RunLoop.main)
            .sink { [weak self] array in
                guard let self else { return }
                self.items = array
                self.applySnapshot(items: array)
            }
            .store(in: &subscriptions)
        
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] msg in
                guard let self else { return }
                let toast = LZSnackToastView(text: msg, showsIcon: false)
                LZSnackToastHelper.showOnce(on: self.view, toast: toast, duration: 3.0)
            }
            .store(in: &subscriptions)
    }
    
    private func initializeEmptySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, WishContentItemEntity>()
        // 2) 섹션만 등록 (.main)
        snapshot.appendSections([.wish])
        // 3) 아이템은 따로 append하지 않음 → 빈 상태
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func fetchData() {
        viewModel.loadInitial()
    }
    
    private func configureFloatingButton() {
        
        view.addSubview(floatingActionButton)
        floatingActionButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-8)
            make.height.equalTo(56)
        }
        
        floatingActionButton.addTarget(self, action: #selector(deleteSelectedItems), for: .touchUpInside)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = true
        
        collectionView.backgroundColor = UIColor(.backgroundDefault)
        // 커스텀 셀 등록
        
        collectionView.register(WishCell.self)
        collectionView.register(MyListCommonHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        collectionView.delegate = self
        collectionView.addPullToRefresh { [weak self] in
            self?.viewModel.hardRefresh()
        }
    }
    
    private func configureEmptyContentLabel() {
        emptyContentsLabel.text = "내목록_빈찜한목록_타이틀".localized
        collectionView.backgroundView = emptyContentsLabel
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            
            let columns = UIDevice.isiPad ? 6 : 3
            
            // 2. 전체 콘텐츠 인셋 및 아이템 간격
            let sideInset: CGFloat = 16
            let interItemSpacing: CGFloat = 16
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
            let group = NSCollectionLayoutGroup.horizontal (
                layoutSize: groupSize,
                subitem: item,
                count: columns
            )
            group.interItemSpacing = .fixed(interItemSpacing)
            group.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: sideInset,
                bottom: 0,
                trailing: sideInset
            )
            
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top:    0,
                leading: 0,
                bottom: 20,
                trailing: 0
            )
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .absolute(64))
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
            
            section.boundarySupplementaryItems = [header]
            section.interGroupSpacing = interGroupSpacing
        
            return section
        }
    }
    
    private func showOverlayView() {
        guard overlayEditView == nil else { return }
        
        let topSafeAreaInsetHeight = LZSUtil.getSafeAreaInsets().top
        let topPadding: CGFloat = 20
        
        let overlay = LZSnackTouchPassthroughView()
        overlay.backgroundColor = UIColor(.backgroundDefault)
        tabmanParent?.view.addSubview(overlay)
        overlay.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(96 + topPadding + topSafeAreaInsetHeight)
        }

        // 3) close 버튼 추가
        let closeButton = UIButton(type: .system)
        let img = UIImage(named: "ic_close")?.resized(to: CGSize(width: 24, height: 24))
        closeButton.setImage(img, for: .normal)
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(toggleEditMode), for: .touchUpInside)

        overlay.addSubview(closeButton)
        
        
        closeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.top.equalToSuperview().inset(topSafeAreaInsetHeight + 8)
            make.size.equalTo(40)
        }
        
        let editTitleLabel = UILabel()
        editTitleLabel.font = .pretendardBold(size: 20)
        editTitleLabel.textColor = .white
        editTitleLabel.text = "편집_버튼_타이틀".localized
        
        overlay.addSubview(editTitleLabel)
        
        editTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalTo(closeButton)
        }
        
        
        let totalCheckBox = LZSnackCheckBox()
        self.totalCheckBox = totalCheckBox
        
        overlay.addSubview(totalCheckBox)
        totalCheckBox.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(24)
            make.bottom.equalToSuperview().offset(-13)
        }
        
        totalCheckBox.setState(.unchecked)
        
        totalCheckBox.addTarget(self,
                                action: #selector(toggleAllCheckboxes(_:)),
                                for: .valueChanged)
        
        let totalCheckBoxTitle = UILabel()
        totalCheckBoxTitle.font = .pretendardMedium(size: 16)
        totalCheckBoxTitle.textColor = .white
        totalCheckBoxTitle.text = "편집_전체선택_타이틀".localized
        
        overlay.addSubview(totalCheckBoxTitle)
        totalCheckBoxTitle.snp.makeConstraints { make in
            make.leading.equalTo(totalCheckBox.snp.trailing).offset(4)
            make.centerY.equalTo(totalCheckBox)
        }

        overlayEditView = overlay
    }
    
    private func hideOverlayView() {
        overlayEditView?.removeFromSuperview()
        overlayEditView = nil
        totalCheckBox = nil
    }
    
    private func configureDataSource() {
        // Diffable Data Source 설정: 커스텀 셀 사용
        dataSource = UICollectionViewDiffableDataSource<Section, WishContentItemEntity>(collectionView: collectionView) { [weak self] collectionView, indexPath, item -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WishCell.reuseIdentifier, for: indexPath) as? WishCell else { return nil }
            guard let self = self else { return nil }
            
            cell.isEditingMode = self.isEditingMode
            cell.configure(with: item)
            cell.updateEditingMode()
            
            return cell
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: MyListCommonHeader.reuseIdentifier,
                for: indexPath) as? MyListCommonHeader else {
                return UICollectionReusableView()
            }
            
            headerView.editButton.addTarget(self,
                                            action: #selector(self?.toggleEditMode),
                                            for: .touchUpInside)
            headerView.historySortButton.addTarget(self,
                                                   action: #selector(self?.didTapSortButton(_:)),
                                        for: .touchUpInside)
            
            
            return headerView
            
        }
    }
    
    private func applySnapshot(items: [WishContentItemEntity]) {
        collectionView.refreshControl?.endRefreshing()
        var snapshot = NSDiffableDataSourceSnapshot<Section, WishContentItemEntity>()
        snapshot.appendSections([.wish])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            self?.updateEmptyState()
        }
    }
}



extension WishListViewController: UICollectionViewDelegate {
    
    @objc private func didTapSortButton(_ sender: UIButton) {

        if isEditingMode { return }
        // 이미 떠 있는 경우 먼저 제거
        presentDropdownMenu(
            anchor: sender,
            menuWidth: max(sender.bounds.width, 120),
            current: WatchHistorySortOption.recent
        ) { [weak self] option in
            guard let self = self else { return }
            sender.setTitle(option.displayName, for: .normal)
            self.applySort(option)
        }
    }
    
    private func applySort(_ option: WatchHistorySortOption) {
        let newSort: ContentsListSort
        switch option {
        case .recent:
            newSort = .recent
            print("최근 순으로 정렬")
        case .old:
            newSort = .oldest
            print("오래된 순으로 정렬")
        case .episodeUpdated:
            newSort = .episodeUpdated
            print("회차 업데이트 순으로 정렬")
        }
        viewModel.updateSort(newSort)
    }

    
    @objc private func toggleAllCheckboxes(_ sender: LZSnackCheckBox) {
        switch sender.checkboxState {
        case .unchecked:
            collectionView.deselectAll()
            updateFloatingActionButton()
        case .checked:
            collectionView.selectAll(using: dataSource)
            updateFloatingActionButton()
        case .partial:
            break
        }
    }
    
    @objc private func toggleEditMode() {
        isEditingMode.toggle()
    }
    
    @objc func deleteSelectedItems() {
        guard let indexPaths = collectionView.indexPathsForSelectedItems, !indexPaths.isEmpty else { return }
        let selected = indexPaths.compactMap { dataSource.itemIdentifier(for: $0) }
        
        view.isUserInteractionEnabled = false
        viewModel.delete(items: selected) { [weak self] success in
            guard let self else { return }
            self.view.isUserInteractionEnabled = true
            
            if success {
                // 스냅샷에서도 제거 (바인딩으로도 갱신되지만 즉시 반영)
                var snapshot = self.dataSource.snapshot()
                snapshot.deleteItems(selected)
                self.dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
                    self?.updateEmptyState()
                    self?.isEditingMode = false
                    let toast = LZSnackToastView(text: "삭제가 완료되었습니다.", showsIcon: false)
                    LZSnackToastHelper.showOnce(on: self?.view, toast: toast, duration: 2.0)
                }
            } else {
                let toast = LZSnackToastView(text: "삭제에 실패했습니다.", showsIcon: false)
                LZSnackToastHelper.showOnce(on: self.view, toast: toast, duration: 2.0)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard viewModel.canPaginate else { return }
        let offY = scrollView.contentOffset.y
        let contentH = scrollView.contentSize.height
        let visibleH = scrollView.bounds.height
        if offY > contentH - visibleH - 400 {
            let lastIndex = max(0, dataSource.snapshot().numberOfItems - 1)
            viewModel.loadNextPageIfNeeded(currentIndex: lastIndex)
        }
    }
    
    private func clearSelectionsAndUI() {
        collectionView.indexPathsForSelectedItems?.forEach {
            collectionView.deselectItem(at: $0, animated: false)
        }
        collectionView.visibleCells.compactMap { $0 as? WishCell }.forEach {
            $0.isSelected = false
            $0.updateEditingMode()
        }
        totalCheckBox?.setState(.unchecked)
        updateFloatingActionButton()
    }
    
    private func updateEmptyState() {
        let snapshot = dataSource.snapshot()
        let itemCount = snapshot.numberOfItems
        
        collectionView.isHidden = false
        
        // itemCount가 0일 때만 backgroundView(빈 상태 레이블)를 보여주고,
        // 그렇지 않으면 backgroundView를 숨겨서 셀만 보이게 함
        collectionView.backgroundView?.isHidden = (itemCount != 0)
    }
    
    
    // 셀 선택 처리
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditingMode {
            // 편집 모드일 땐 기존 셀렉션 로직
            updateHeaderCheckbox()
            updateFloatingActionButton()
        } else {
            // 일반 모드일 땐 '탭' 이벤트로 처리
            collectionView.deselectItem(at: indexPath, animated: true)
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
            handleTap(on: item)
        }
    }
    
    private func handleTap(on item: WishContentItemEntity) {
        let playInput = PlayInput(contentsAlias: item.contentsAlias, episodeAlias: "")
        let route = ViewerRoute.main(playInput)
        guard let vc = AppContext.container.resolve(ViewerViewController.self,arguments: ViewerType.mainViewer, route) else { return }
        navigationController?.pushHidesBottomBarViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard isEditingMode else { return }
        updateHeaderCheckbox()
        updateFloatingActionButton()
    }
    
    private func updateHeaderCheckbox() {
        let state = collectionView.selectionState(
            dataSource: dataSource,
            sectionID: .wish, sectionIndex: 0
        )
        switch state {
        case .unchecked:
            guard let totalCheckBox = totalCheckBox else { return }
            totalCheckBox.setState(.unchecked)
        case .partial:
            guard let totalCheckBox = totalCheckBox else { return }
            totalCheckBox.setState(.partial)
        case .checked:
            guard let totalCheckBox = totalCheckBox else { return }
            totalCheckBox.setState(.checked)
        }
    }
    
    
    private func updateFloatingActionButton() {
        guard let selectedIndexPaths = collectionView.indexPathsForSelectedItems else { return }
        let selectedItems = selectedIndexPaths.compactMap { dataSource.itemIdentifier(for: $0) }
        let selectedItemsString = "편집_N개_삭제".localized(with: selectedItems.count)
        
        UIView.performWithoutAnimation {
            floatingActionButton.setTitle(selectedItemsString, for: .normal)
            
            if selectedItems.count > 0 {
                floatingActionButton.backgroundColor = UIColor(.brandRed)
                floatingActionButton.tintColor = .white
            } else {
                floatingActionButton.backgroundColor = UIColor(.fillDisabled)
                floatingActionButton.tintColor = UIColor(.foregroundDisabled)
            }
        }
    }
}
