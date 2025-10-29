//
//  UsageHistoryViewController.swift
//  LezhinSnack
//
//  Created by 신진우 on 5/22/25.
//


import UIKit

final class UsageHistoryViewController: UIViewController {
    
    enum Section {
        case history
    }
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, CoinUsageEntity>!
    private var overlayEditView: UIView?
    
    private let emptyContentsLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 14)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private var pendingItems: [CoinUsageEntity]?
    
    weak var delegate: ChildCoinHistoryDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        if let items = pendingItems {
            pendingItems = nil
            applySnapshot(items: items)
        }
        
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(.backgroundDefault)
        
        configureCollectionView()
        configureDataSource()
        configureEmptyContentLabel()
        delegate?.loadUsageHistory()
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
        
        collectionView.register(UsageCell.self)
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        collectionView.addPullToRefresh { [weak self] in
            self?.initializeEmptySnapshot()
//            self?.delegate?.loadUsageHistory()
            self?.delegate?.reloadUsageHistory()
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(80))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(80))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, CoinUsageEntity>(collectionView: collectionView) { [weak self] collectionView, indexPath, item -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UsageCell.reuseIdentifier, for: indexPath) as? UsageCell else { return nil }
            
            cell.configure(item)
            
            return cell
        }
    }
    
    private func initializeEmptySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CoinUsageEntity>()
        snapshot.appendSections([.history])
        snapshot.appendItems([])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func applySnapshot(items: [CoinUsageEntity]) {
        guard let dataSource = dataSource else {
            // 아직 dataSource가 없으면 보관
            pendingItems = items
            return
        }
        collectionView.refreshControl?.endRefreshing()
        var snapshot = NSDiffableDataSourceSnapshot<Section, CoinUsageEntity>()
        snapshot.appendSections([.history])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: true){ [weak self] in
            self?.updateEmptyState()
        }
    }
}

extension UsageHistoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        delegate?.loadMoreUsageIfNeeded(visibleIndex: indexPath.item)
    }
}
