//
//  ChargeHistoryViewController.swift
//  LezhinSnack
//
//  Created by 신진우 on 5/22/25.
//


import UIKit
import SnapKit

final class RechargeHistoryViewController: UIViewController {
    
    enum Section {
        case history
    }
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, CoinChargeEntity>!
    private var overlayEditView: UIView?
    
    private var currentCoinBalance = ""
    private var expiringWindowDays: String = ""
    
    private var selectedSort: MyCoinSortOption = .total
    
    weak var delegate: ChildCoinHistoryDelegate?
    
    private let emptyContentsLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 14)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    init(currentCoinBalance: String, expiringWindowDays: String) {
        self.currentCoinBalance = currentCoinBalance
        self.expiringWindowDays = expiringWindowDays
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(.backgroundDefault)
        
//        setCoinInfoViewText()
        
        configureCollectionView()
        configureDataSource()
        
        delegate?.loadCoinChargeHistory()
    }
    
    private func configureEmptyContentLabel() {
        emptyContentsLabel.text = "내목록_빈시청목록_타이틀".localized
        collectionView.backgroundView = emptyContentsLabel
    }
    
    private func updateEmptyState() {
        let itemCount = dataSource.snapshot().numberOfItems
        collectionView.isHidden = false
        collectionView.backgroundView?.isHidden = (itemCount != 0)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = true
        
        collectionView.backgroundColor = UIColor(.backgroundDefault)
        // 커스텀 셀 등록
        
        collectionView.register(RechargeCell.self)
        collectionView.register(MyCoinCommonHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        collectionView.addPullToRefresh { [weak self] in
            guard let self else { return }
            self.initializeEmptySnapshot()
            self.delegate?.reloadCoinChargeHistory()
            
        }
        //collectionView.bounces = false
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(80))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(80))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(104))
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        
        section.boundarySupplementaryItems = [header]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, CoinChargeEntity>(collectionView: collectionView) { [weak self] collectionView, indexPath, item -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RechargeCell.reuseIdentifier, for: indexPath) as? RechargeCell else { return nil }
            
            cell.configure(item)
            
            return cell
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: MyCoinCommonHeader.reuseIdentifier,
                for: indexPath) as? MyCoinCommonHeader else {
                return UICollectionReusableView()
            }
            
            guard let self else { return UICollectionReusableView()}
            headerView.setCoinInfoViewText(setCoinText: self.currentCoinBalance, expiredCoinText: self.expiringWindowDays)
            headerView.updateSortTitle(self.selectedSort)
            headerView.delegate = self
            
            return headerView
            
        }
        collectionView.delegate = self  //  페이지네이션용
    }
    
    private func initializeEmptySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CoinChargeEntity>()
        snapshot.appendSections([.history])
        snapshot.appendItems([])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func getHeaderView() -> MyCoinCommonHeader? {
        return collectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: 0)
        ) as? MyCoinCommonHeader
    }
    
    func applySnapshot(items: [CoinChargeEntity]) {
        collectionView.refreshControl?.endRefreshing()
        var snapshot = NSDiffableDataSourceSnapshot<Section, CoinChargeEntity>()
        snapshot.appendSections([.history])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: true){ [weak self] in
            self?.updateEmptyState()
        }
    }
    
}


extension RechargeHistoryViewController: MyCoinCommonHeaderDelegate {
    
    func sortButtonDidTap(header: MyCoinCommonHeader, anchor: UIView) {
        presentDropdownMenu(
            anchor: anchor,
            menuWidth: 120,
            current: selectedSort
        ) { [weak self] option in
            guard let self = self else { return }
            header.updateSortTitle(option)
            self.applySort(option)
            self.delegate?.changeChargeFilter(option.toFilter)
        }
    }
    
    
    private func applySort(_ option: MyCoinSortOption) {
        switch option {
        case .total:    print("전체 순")
            
        case .expired:  print("만료 순")
        }
        // 데이터 정렬 후 snapshot 갱신 …
    }
}

extension RechargeHistoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        delegate?.loadMoreCoinChargesIfNeeded(visibleIndex: indexPath.item) // 다음 페이지 판단은 VM에서
    }
}
