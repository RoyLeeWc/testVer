//
//  EpisodeDetailViewController.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/2/25.
//

import UIKit

final class ContentsDetailViewController: UIViewController {
    
    enum DetailSection: Hashable {
        case detail(id: UUID, title: String)
    }
    
    private var sections: [DetailSection] = []
    
    let sectionData = [
        (id: UUID(), title: "장르"),
        (id: UUID(), title: "키워드"),
        (id: UUID(), title: "줄거리")
    ]
    
    struct Item: Hashable {
        let id = UUID()
        let title: String
    }
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<DetailSection, Item>!
    
    var items: [Item] = (0..<200).map { Item(title: "Item \($0)") }
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
    
    override func viewDidLoad() {
        setupUI()
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
        
        collectionView.register(ContentsDetailCell.self)
        collectionView.register(ContentsDetailParentHeader.self,
                                forSupplementaryViewOfKind: "global-header")
        
        collectionView.register(ContentsDetailSectionHeader.self,
                                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.snp.bottom)
        }
        
        collectionView.delegate = self
        //collectionView.bounces = false
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let spacing: CGFloat = 8

        // 1) 아이템 크기 & 그룹 정의
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 1
        )
        group.interItemSpacing = .fixed(spacing)

        // 2) 섹션 생성
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)

        // 3) 섹션 헤더 추가 (등록 시:
        // collectionView.register(ContentsDetailParentHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        let sectionHeaderSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [sectionHeader]

        // 4) 글로벌 헤더 추가 (등록 시:
        // collectionView.register(ContentsDetailGlobalHeader.self, forSupplementaryViewOfKind: "global-header")
        let globalHeaderSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(160)
        )
        let globalHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: globalHeaderSize,
            elementKind: "global-header",
            alignment: .top
        )
        globalHeader.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)

        // 5) 레이아웃 구성에 글로벌 헤더 설정
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.boundarySupplementaryItems = [globalHeader]

        return UICollectionViewCompositionalLayout(
            section: section,
            configuration: config
        )
    }
    
    private func applySnapshot() {
        // 1) 섹션 생성
        sections = sectionData.map { .detail(id: $0.id, title: $0.title) }

        // 2) 스냅샷 초기화 및 섹션 추가
        var snapshot = NSDiffableDataSourceSnapshot<DetailSection, Item>()
        snapshot.appendSections(sections)

        // 3) 섹션별로 한 개의 아이템만 추가
        let texts = [
            "장르・장르・장르장르・장르・장르장르・장르・장르장르・장르・장르장르・장르・장르장르・장르・장르장르・장르・장르장르・장르・장르장르・장르・장르장르・장르・장르장르・장르・장르장르・장르・장르장르・장르・장르장르・장르・장르장르・장르・장르장르・장르・장르장르・장르・장르장르・장르・장르장르・장르・장르장르・장르・장르장르・장르・장르장르・장르・장르",
            "키워드・키워드・키워드키워드・키워드・키워드키워드・키워드・키워드키워드・키워드・키워드키워드・키워드・키워드키워드・키워드・키워드키워드・키워드・키워드키워드・키워드・키워드키워드・키워드・키워드키워드・키워드・키워드키워드・키워드・키워드키워드・키워드・키워드키워드・키워드・키워드키워드・키워드・키워드",
            "전 세계 헌터 중 유일무이, 전무후무 시스템과 레벨업 능력을 각성한 진우. 세상을 향해 자유를 선포한다! 전 세계 헌터 중 유일무이, 전무후무 시스템과 레벨업 능력을 각성한 진우.전 세계 헌터 중 유일무이, 전무후무 시스템과 레벨업 능력을 각성한 진우. 세상을 향해 자유를 선포한다! 전 세계 헌터 중 유일무이, 전무후무 시스템과 레벨업 능력을 각성한 진우.전 세계 헌터 중 유일무이, 전무후무 시스템과 레벨업 능력을 각성한 진우. 세상을 향해 자유를 선포한다! 전 세계 헌터 중 유일무이, 전무후무 시스템과 레벨업 능력을 각성한 진우.전 세계 헌터 중 유일무이, 전무후무 시스템과 레벨업 능력을 각성한 진우. 세상을 향해 자유를 선포한다! 전 세계 헌터 중 유일무이, 전무후무 시스템과 레벨업 능력을 각성한 진우.전 세계 헌터 중 유일무이, 전무후무 시스템과 레벨업 능력을 각성한 진우. 세상을 향해 자유를 선포한다! 전 세계 헌터 중 유일무이, 전무후무 시스템과 레벨업 능력을 각성한 진우.전 세계 헌터 중 유일무이, 전무후무 시스템과 레벨업 능력을 각성한 진우. 세상을 향해 자유를 선포한다! 전 세계 헌터 중 유일무이, 전무후무 시스템과 레벨업 능력을 각성한 진우.전 세계 헌터 중 유일무이, 전무후무 시스템과 레벨업 능력을 각성한 진우. 세상을 향해 자유를 선포한다! 전 세계 헌터 중 유일무이, 전무후무 시스템과 레벨업 능력을 각성한 진우.전 세계 헌터 중 유일무이, 전무후무 시스템과 레벨업 능력을 각성한 진우. 세상을 향해 자유를 선포한다! 전 세계 헌터 중 유일무이, 전무후무 시스템과 레벨업 능력을 각성한 진우.전 세계 헌터 중 유일무이, 전무후무 시스템과 레벨업 능력을 각성한 진우. 세상을 향해 자유를 선포한다! 전 세계 헌터 중 유일무이, 전무후무 시스템과 레벨업 능력을 각성한 진우.전 세계 헌터 중 유일무이, 전무후무 시스템과 레벨업 능력을 각성한 진우. 세상을 향해 자유를 선포한다! 전 세계 헌터 중 유일무이, 전무후무 시스템과 레벨업 능력을 각성한 진우.전 세계 헌터 중 유일무이, 전무후무 시스템과 레벨업 능력을 각성한 진우. 세상을 향해 자유를 선포한다! 전 세계 헌터 중 유일무이, 전무후무 시스템과 레벨업 능력을 각성한 진우.전 세계 헌터 중 유일무이, 전무후무 시스템과 레벨업 능력을 각성한 진우. 세상을 향해 자유를 선포한다! 전 세계 헌터 중 유일무이, 전무후무 시스템과 레벨업 능력을 각성한 진우.전 세계 헌터 중 유일무이, 전무후무 시스템과 레벨업 능력을 각성한 진우. 세상을 향해 자유를 선포한다! 전 세계 헌터 중 유일무이, 전무후무 시스템과 레벨업 능력을 각성한 진우."
        ]

        for (index, section) in sections.enumerated() {
            let singleItem = Item(title: texts[index])
            snapshot.appendItems([singleItem], toSection: section)
        }

        // 4) 데이터 소스에 적용
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
        dataSource = UICollectionViewDiffableDataSource<DetailSection, Item>(collectionView: collectionView) { [weak self] collectionView, indexPath, item -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentsDetailCell.reuseIdentifier, for: indexPath) as? ContentsDetailCell else { return nil }
            
            cell.configure(content: item.title)
            
            return cell
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            switch kind {
            case "global-header":
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: ContentsDetailParentHeader.reuseIdentifier,
                    for: indexPath
                ) as? ContentsDetailParentHeader else { return UICollectionReusableView()}
                // 글로벌 헤더 설정
                header.headerTitle.text = "레진코믹스 12주간 로맨스 TOP 1 원작 웹툰"
                header.headerSubTitle.text = "2025・에피소드 72개"
                let icons = [
                    "ic_rating_15_color",
                    "ic_sexuality_color",
                    "ic_imitative_color",
                    "ic_theme_color"
                ].compactMap { name -> UIImage? in
                    UIImage(named: name)?.resized(to: .init(width: 24, height: 24))
                }
                header.addImagesToStack(icons)
                return header

            case UICollectionView.elementKindSectionHeader:
                let section = self?.sections[indexPath.section]
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: ContentsDetailSectionHeader.reuseIdentifier,
                    for: indexPath
                ) as? ContentsDetailSectionHeader else { return UICollectionReusableView()}

                if case let .detail(_, title) = section {
                    header.headerTitle.text = title
                }
                return header

            default:
                return nil
            }
        }
    }
    
}


extension ContentsDetailViewController: UICollectionViewDelegate {
    
    
}
