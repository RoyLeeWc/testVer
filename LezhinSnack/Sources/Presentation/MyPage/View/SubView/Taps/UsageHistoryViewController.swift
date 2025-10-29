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
    private var dataSource: UICollectionViewDiffableDataSource<Section, PurchaseHistoryEntity>!
    private var overlayEditView: UIView?
    
    weak var delegate: ChildCoinHistoryDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(.backgroundDefault)
        
//        setCoinInfoViewText()
        
        configureCollectionView()
        configureDataSource()
        
        delegate?.loadUsageHistory()
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
            self?.delegate?.loadUsageHistory()
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
        // Diffable Data Source 설정: 커스텀 셀 사용
        dataSource = UICollectionViewDiffableDataSource<Section, PurchaseHistoryEntity>(collectionView: collectionView) { [weak self] collectionView, indexPath, item -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UsageCell.reuseIdentifier, for: indexPath) as? UsageCell else { return nil }
            
            cell.configure(item)
            
            return cell
        }
    }
    
    private func initializeEmptySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PurchaseHistoryEntity>()
        snapshot.appendSections([.history])
        snapshot.appendItems([])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func applySnapshot(items: [PurchaseHistoryEntity] = []) {
        collectionView.refreshControl?.endRefreshing()
        var snapshot = NSDiffableDataSourceSnapshot<Section, PurchaseHistoryEntity>()
        snapshot.appendSections([.history])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
            //self?.updateEmptyState()
        }
    }
    
}

