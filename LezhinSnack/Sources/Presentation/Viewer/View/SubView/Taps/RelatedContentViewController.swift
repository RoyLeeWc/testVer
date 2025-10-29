//
//  EpisodeListViewController.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/30/25.
//
import UIKit
import SnapKit


final class RelatedContentViewController: UIViewController {
    
    enum Section {
        case history
    }
    
    struct Item: Hashable {
        let id = UUID()
        let title: String
    }
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    var items: [Item] = (0..<200).map { Item(title: "Item \($0)") }
    
    override func viewDidLoad() {
        setupUI()
    }
    
    // 최하단 그라디언트 뷰
    private let gradientView: UIView = {
        let view = UIView()
        view.isHidden = true                // 기본적으로 숨김. scrollable 시 보여줌
        view.backgroundColor = .clear        // 배경 투명
        return view
    }()
    
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
        configureGradientView()
        configureDataSource()
        applySnapshot()
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
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsSelection = true
        collectionView.backgroundColor = UIColor(.clear)
        // 커스텀 셀 등록
        
        collectionView.register(RelatedContentCell.self)
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.snp.bottom)
        }
        
        collectionView.delegate = self
        //collectionView.bounces = false
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(78))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.history])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            guard let self = self else { return }
            // 스냅샷 적용 직후 contentSize 재확인
            self.collectionView.layoutIfNeeded()
            let isScrollable = self.collectionView.contentSize.height > self.collectionView.bounds.height
            self.gradientView.isHidden = !isScrollable
        }
    }
    
    
    private func configureDataSource() {
        // Diffable Data Source 설정: 커스텀 셀 사용
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { [weak self] collectionView, indexPath, item -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RelatedContentCell.reuseIdentifier, for: indexPath) as? RelatedContentCell else { return nil }
            
            cell.configure()
            
            
            return cell
        }
    }
}


extension RelatedContentViewController: UICollectionViewDelegate {
    
    
}
