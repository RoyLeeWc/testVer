//
//  Paginator.swift
//  LezhinSnack
//
//  Created by lwc on 10/2/25.
//

import Foundation

/// API가 `PagedEntity<Item>`을 주는 전제
final class Paginator<Item: Hashable> {
    typealias Fetch = (_ page: Int, _ size: Int) async throws -> PagedEntity<Item>

    private let size: Int
    private let fetch: Fetch

    private(set) var page: Int = 0
    private(set) var isLast: Bool = false
    private(set) var isLoading: Bool = false
    private(set) var items: [Item] = []

    init(size: Int = 20, fetch: @escaping Fetch) {
        self.size = size
        self.fetch = fetch
    }

    func reset() {
        page = 0
        isLast = false
        isLoading = false
        items.removeAll()
    }

    /// 다음 페이지 로드. 이미 마지막/로딩중이면 현재 items 그대로 반환.
    @discardableResult
    func loadNext() async throws -> [Item] {
        guard !isLoading, !isLast else { return items }
        isLoading = true
        defer { isLoading = false }

        let pageResult = try await fetch(page, size)
        items.append(contentsOf: pageResult.items)
        page += 1
        isLast = pageResult.isLast
        return items
    }
}
