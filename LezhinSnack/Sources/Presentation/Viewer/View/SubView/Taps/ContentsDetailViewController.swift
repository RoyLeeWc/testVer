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
    private let ratingTypeIconMap: [String: String] = [
        "ALL":  "ic_rating_all_color",
        "PG12": "ic_rating_12_color",
        "PG15": "ic_rating_15_color",
        "R19":  "ic_rating_19_color",
    ]
    
    private let ratingReasonIconMap: [String: String] = [
        "SUBJECT" :         "ic_subject_color",
        "SEXUALITY":       "ic_sexuality_color",
        "VIOLENCE":        "ic_violence_color",
        "DIALOGUE":        "ic_dialogue_color",
        "HORROR":          "ic_horror_color",
        "DRUGS":           "ic_drugs_color",
        "IMITATION_RISK":  "ic_imitative_color"
    ]
    
    private func promotionType(from contractType: String?) -> LZSnackPromotionViewType? {
        guard let t = contractType?.uppercased() else { return nil }
        
        switch t {
        case "LEZHIN_ORIGINAL":   return .lezhinIPIcons
        case "BOMTOON_ORIGINAL":  return .bomtoonIPIcons
        case "GENERAL_ORIGINAL":  return .originalIcons
        case "OTHERS":            return nil   // 뱃지 표시 안 함
        default:                  return nil
        }
    }
    
    private let roleLabelMap: [String: String] = [
        "DIRECTOR": "감독",
        "WRITER":   "작가",
        "PRODUCER": "프로듀서"
    ]
                    
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
    
    private var contents: DisplayContentsDetailEntity?
    
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
    
    func attach(contents: DisplayContentsDetailEntity) {
        self.contents = contents
        if isViewLoaded { applySnapshot() }
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
        var pairs: [(title: String, value: String)] = []
        
        guard let detailedContents = contents else {
            // 데이터 없으면 섹션/아이템 비우기
            sections = []
            var emptySnap = NSDiffableDataSourceSnapshot<DetailSection, Item>()
            dataSource.apply(emptySnap, animatingDifferences: false)
            return
        }
        
        // 1) 장르
        let genreNames = detailedContents.genreTags
            .sorted { ($0.orderNumber ?? 0) < ($1.orderNumber ?? 0) }
            .map { $0.name }
        if !genreNames.isEmpty {
            pairs.append(("장르", genreNames.joined(separator: "・")))
        }
        
        // 2) 키워드
        let keywordNames = detailedContents.keywordTags
            .sorted { ($0.orderNumber ?? 0) < ($1.orderNumber ?? 0) }
            .map { $0.name }
        if !keywordNames.isEmpty {
            pairs.append(("키워드", keywordNames.joined(separator: "・")))
        }
        
        // 3) 줄거리
        if let s = detailedContents.synopsis, !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            pairs.append(("줄거리", s))
        }
        
        // 4) 출연진(APPEARANCE)
        let castNames = detailedContents.creators
            .filter { $0.creatorRoleType.uppercased() == "APPEARANCE" }
            .map { $0.realName }
        if !castNames.isEmpty {
            pairs.append(("출연진", castNames.joined(separator: ",")))
        }
        
        // 5) 크리에이터(DIRECTOR/WRITER/PRODUCER 묶음)
        let creatorRolesOrder = ["DIRECTOR", "WRITER", "PRODUCER"]
        var creatorLines: [String] = []
        for role in creatorRolesOrder {
            let names = detailedContents.creators
                .filter { $0.creatorRoleType.uppercased() == role }
                .map { $0.realName }
            if !names.isEmpty, let label = roleLabelMap[role] {
                creatorLines.append("\(label): \(names.joined(separator: ","))")
            }
        }
        if !creatorLines.isEmpty {
            pairs.append(("크리에이터", creatorLines.joined(separator: "\n")))
        }
        
        // 섹션/아이템 스냅샷 적용 (요청한 순서 유지: 장르 → 키워드 → 줄거리 → 출연진 → 크리에이터)
        sections = pairs.map { .detail(id: UUID(), title: $0.title) }
        
        var snapshot = NSDiffableDataSourceSnapshot<DetailSection, Item>()
        snapshot.appendSections(sections)
        
        for (idx, p) in pairs.enumerated() {
            snapshot.appendItems([Item(title: p.value)], toSection: sections[idx])
        }
        
        dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            guard let self = self else { return }
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
                if let headerContents = self?.contents {
                    
                    header.headerTitle.text = headerContents.signatureText ?? headerContents.title
                    
                    let date = Date()
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.year, .month, .day], from: date)
                    let year = String(components.year ?? 2025)
                    header.headerSubTitle.text = "\(year)・에피소드 \(headerContents.episodeCount)개"
                    
                    // 프로모션 뱃지 주입
                    header.setPromotionType(self?.promotionType(from:headerContents.contractType))
                    
                    var iconNames: [String] = []
                    if let ageRatingType = headerContents.ageRatingType,
                       let badge = self?.ratingTypeIconMap[ageRatingType] {
                        iconNames.append(badge)
                    }
                    for ageRatingReasons in headerContents.ageRatingReasons {
                        let key = ageRatingReasons.uppercased()
                        if let name = self?.ratingReasonIconMap[key] {
                            iconNames.append(name)
                        }
                    }
                    let icons: [UIImage] = iconNames
                        .compactMap { UIImage(named: $0)?.resized(to: .init(width: 24, height: 24)) }
                    header.addImagesToStack(icons)
                } else {
                    header.headerTitle.text = "레진코믹스 12주간 로맨스 TOP 1 원작 웹툰"
                    header.headerSubTitle.text = "2025・에피소드 72개"
                    header.setPromotionType(nil)
                    let icons = [
                        "ic_rating_15_color",
                        "ic_sexuality_color",
                        "ic_imitative_color",
                        "ic_subject_color"
                    ].compactMap { name -> UIImage? in
                        UIImage(named: name)?.resized(to: .init(width: 24, height: 24))
                    }
                    header.addImagesToStack(icons)
                }
                
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
