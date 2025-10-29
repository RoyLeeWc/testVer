//
//  Collections.swift
//  LezhinSnack
//
//  Created by lwc on 9/12/25.
//

import UIKit

final class DiffableSerialApplier<Section: Hashable, Item: Hashable> {

    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>

    private weak var dataSource: UICollectionViewDiffableDataSource<Section, Item>?
    private var queue: [Operation] = []
    private var isApplying = false
    private let log: Bool

    private enum Operation {
        case full(Snapshot, Bool, (() -> Void)?)
        case section(Section, SectionSnapshot, Bool, (() -> Void)?)
    }

    init(dataSource: UICollectionViewDiffableDataSource<Section, Item>, log: Bool = false) {
        self.dataSource = dataSource
        self.log = log
    }

    // 1) 전체 스냅샷 적용 (가장 강력, 다른 대기 작업을 모두 대체)
    func applyFull(_ snapshot: Snapshot,
                   animatingDifferences: Bool = true,
                   completion: (() -> Void)? = nil) {
        dispatchPrecondition(condition: .onQueue(.main)) // 반드시 메인
        // full이 오면 이전 작업은 의미 없어질 수 있으므로 큐 비우고 최신 것만
        queue.removeAll()
        queue.append(.full(snapshot, animatingDifferences, completion))
        drain()
    }

    // 2) 특정 섹션만 업데이트 (섹션 단위 비동기 갱신용)
    func applySection(_ section: Section,
                      items: [Item],
                      animatingDifferences: Bool = true,
                      completion: (() -> Void)? = nil) {
        dispatchPrecondition(condition: .onQueue(.main))
        var ss = SectionSnapshot()
        ss.append(items)
        // 같은 섹션에 대한 이전 대기 작업은 최신으로 교체(코얼레스)
        queue.removeAll { op in
            if case let .section(sec, _, _, _) = op { return sec == section }
            return false
        }
        queue.append(.section(section, ss, animatingDifferences, completion))
        drain()
    }

    // 내부: 큐를 한 번에 하나씩 처리
    private func drain() {
        guard !isApplying, !queue.isEmpty else { return }
        isApplying = true
        let op = queue.removeFirst()

        if log { print("🔧 DiffableSerialApplier start: \(opDescription(op))  queue:\(queue.count)") }

        switch op {
        case let .full(snapshot, anim, completion):
            dataSource?.apply(snapshot, animatingDifferences: anim, completion: { [weak self] in
                if self?.log == true { print("✅ full applied") }
                completion?()
                self?.isApplying = false
                self?.drain()
            })

        case let .section(section, ss, anim, completion):
            dataSource?.apply(ss, to: section, animatingDifferences: anim, completion: { [weak self] in
                if self?.log == true { print("✅ section applied: \(section)") }
                completion?()
                self?.isApplying = false
                self?.drain()
            })
        }
    }

    private func opDescription(_ op: Operation) -> String {
        switch op {
        case .full: return "full"
        case let .section(section, _, _, _): return "section(\(section))"
        }
    }
}
