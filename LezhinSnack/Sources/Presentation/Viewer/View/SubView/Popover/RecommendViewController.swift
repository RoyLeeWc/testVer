// RecommendViewController.swift
// LezhinSnack
//
// Created by jinu0115 on 5/7/25.
//

import UIKit
import SnapKit

final class RecommendViewController: UIViewController {

    enum Section {
        case main
    }

    struct Item: Hashable {
        let identifier: UUID
        let title: String
    }
    
    
    private let footerHeight: CGFloat =  44 + 16 + 22 + 32

    // 원본 추천 항목
    private let originalItems: [Item] = (1...10).map { index in
        Item(identifier: UUID(), title: "Item \(index)")
    }

    // 무한 캐러셀용으로 복제된 항목
    private var infiniteItems: [Item] = []
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    private lazy var collectionView: UICollectionView = {
        let compositionalLayout = makeLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
        collectionView.register(RecommendVideoCell.self)
        collectionView.register(RecommendFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.bounces = false
        return collectionView
    }()

    private let closeActionButton: UIButton = {
        let button = UIButton(type: .custom)
        let closeImage = UIImage(named: "ic_close")?.resized(to: CGSize(width: 24, height: 24))
        button.setImage(closeImage, for: .normal)
        return button
    }()

    private let sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 20)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "이 작품을 본 사람들이\n 추천하는 다른 작품"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(.backgroundDefault)
        setupUI()
        configureDataSource()
    }

    private func setupUI() {
        view.addSubview(closeActionButton)
        closeActionButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.trailing.equalToSuperview().inset(12)
            make.width.height.equalTo(40)
        }
        closeActionButton.addTarget(self,
                                    action: #selector(didTapCloseButton),
                                    for: .touchUpInside)

        view.addSubview(sectionTitleLabel)
        sectionTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(closeActionButton.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(56)
        }

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(sectionTitleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(452 + footerHeight )
        }
    }

    private func makeLayout() -> UICollectionViewLayout {
        // 중앙 셀 크기
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(254),
            heightDimension: .absolute(452)
        )
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)

        // 그룹에는 한 개 레이아웃 아이템 배치
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(254),
            heightDimension: .absolute(452)
        )
        let layoutGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [layoutItem]
        )

        // 섹션 정의
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
        layoutSection.visibleItemsInvalidationHandler = { [weak self] visibleItems, contentOffset, environment in
            guard let self = self else { return }
            let centerX = contentOffset.x + environment.container.contentSize.width / 2

            // 가장 중앙에 가까운 아이템 찾기 및 스케일 적용
            var minimalDistance = CGFloat.greatestFiniteMagnitude
            var closestItem: NSCollectionLayoutVisibleItem?

            for layoutVisibleItem in visibleItems {
                // 셀만 처리
                guard layoutVisibleItem.representedElementKind == nil else { continue }

                let distance = abs(layoutVisibleItem.center.x - centerX)
                let maxDistance = layoutVisibleItem.bounds.width
                let normalizedDistance = min(distance / maxDistance, 1)
                let scaleFactor = 1 - (normalizedDistance * 0.2)
                layoutVisibleItem.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)

                if distance < minimalDistance {
                    minimalDistance = distance
                    closestItem = layoutVisibleItem
                }
            }

            // footer 업데이트
            if let closest = closestItem {
                let currentIndex = closest.indexPath.item % self.originalItems.count
                let totalPageCount = self.originalItems.count
                DispatchQueue.main.async {
                    let footerIndexPath = IndexPath(item: 0, section: 0)
                    if let footerView = self.collectionView
                        .supplementaryView(
                            forElementKind: UICollectionView.elementKindSectionFooter,
                            at: footerIndexPath
                        ) as? RecommendFooterView {
                        footerView.updateCurrentIndex(currentIndex, totalPages: totalPageCount)
                    }
                }
            }
        }

        // Footer 정의
        let footerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(footerHeight)
        )
        let footerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
        layoutSection.boundarySupplementaryItems = [footerItem]

        return UICollectionViewCompositionalLayout(section: layoutSection)
    }

    @objc private func didTapCloseButton() {
        dismiss(animated: true)
    }

    private func configureDataSource() {
        // 데이터 복제
        infiniteItems = originalItems.flatMap { baseItem in
            return (0..<3).map { _ in
                Item(identifier: UUID(), title: baseItem.title)
            }
        }

        dataSource = UICollectionViewDiffableDataSource<Section, Item>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            guard let carouselCell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: RecommendVideoCell.reuseIdentifier,
                    for: indexPath
            ) as? RecommendVideoCell else {
                return UICollectionViewCell()
            }
            carouselCell.configure(with: item.title)
            return carouselCell
        }

        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionFooter,
                  let self = self,
                  let footerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: RecommendFooterView.reuseIdentifier,
                    for: indexPath
                  ) as? RecommendFooterView else { return nil }
            // 초기 footer 인디케이터 세팅 (원본 첫 페이지)
            footerView.updateCurrentIndex(0, totalPages: self.originalItems.count)
            
            let keywords = ["키워드1", "키워드2", "키워드3"]
            footerView.updateCurrentKeyword(keywords: keywords)
            
            return footerView
        }

        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(infiniteItems, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            guard let self = self else { return }
            self.collectionView.layoutIfNeeded()
            DispatchQueue.main.async {
                let middleIndex = self.originalItems.count      // 10
                let middleIndexPath = IndexPath(item: middleIndex, section: 0)
                self.collectionView.scrollToItem(
                    at: middleIndexPath,
                    at: .centeredHorizontally,
                    animated: false
                )
            }
        }
    }
}

extension RecommendViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 무한 스크롤 위치 보정
        guard !infiniteItems.isEmpty else { return }
        let totalCount = infiniteItems.count
        let centerSection = originalItems.count

        // 가장 중앙에 가까운 셀 찾기
        let visibleCenterPaths = collectionView.indexPathsForVisibleItems
        let closestPath = visibleCenterPaths.min {
            abs($0.item - centerSection) < abs($1.item - centerSection)
        }
        guard let closest = closestPath else { return }
        var adjustedItem = closest.item

        if adjustedItem < centerSection {
            adjustedItem += originalItems.count
        } else if adjustedItem >= centerSection * 2 {
            adjustedItem -= originalItems.count
        } else {
            return
        }

        let adjustedIndexPath = IndexPath(item: adjustedItem, section: 0)
        collectionView.scrollToItem(
            at: adjustedIndexPath,
            at: .centeredHorizontally,
            animated: false
        )
    }
}
