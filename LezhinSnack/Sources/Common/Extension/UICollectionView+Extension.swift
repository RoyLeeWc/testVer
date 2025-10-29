//
//  UICollectionView+Extension.swift
//  LezhinSnack
//
//  Created by 신진우 on 4/19/25.
//
import UIKit

enum SelectionState {
    case unchecked   // 선택된 항목이 없음
    case partial     // 일부만 선택됨
    case checked     // 모두 선택됨
}

extension UICollectionView {
    func selectionState<Item, SectionID: Hashable>(
        dataSource: UICollectionViewDiffableDataSource<SectionID, Item>,
        sectionID: SectionID,
        sectionIndex: Int
    ) -> SelectionState {
        let snapshot = dataSource.snapshot()
        let total = snapshot.numberOfItems(inSection: sectionID)
        let selected = indexPathsForSelectedItems?
            .filter { $0.section == sectionIndex }
            .count ?? 0

        switch selected {
        case 0:
            return .unchecked
        case total:
            return .checked
        default:
            return .partial
        }
    }
    
    // 전체 선택
    func selectAll<Item, SectionID: Hashable>(
        using dataSource: UICollectionViewDiffableDataSource<SectionID, Item>) {
        let snapshot = dataSource.snapshot()
        snapshot.sectionIdentifiers.forEach { sectionIdentifier in
            guard let sectionIndex = snapshot.indexOfSection(sectionIdentifier) else { return }
            let itemCount = snapshot.numberOfItems(inSection: sectionIdentifier)
            for itemIndex in 0..<itemCount {
                let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                self.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
        }
    }

    // 전체 해제
    func deselectAll() {
        (self.indexPathsForSelectedItems ?? []).forEach { indexPath in
            self.deselectItem(at: indexPath, animated: false)
        }
    }
}
