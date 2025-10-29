//
//  RecentSearchService.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/27/25.
//

import RealmSwift
import Foundation

/// 검색 기록 모델
final class RecentSearch: Object {
    @Persisted(primaryKey: true) var keyword: String = ""
    @Persisted var timestamp: Date = Date()
}

/// Realm 기반 RecentSearchService
final class RecentSearchService {
    static let shared = RecentSearchService()
    private init() { }
    
    private let realmQueue = RealmQueue.shared.queue

    /// Realm 인스턴스를 안전하게 반환
    private func getRealm() -> Realm? {
        do {
            return try Realm()
        } catch {
            print("Realm 초기화 오류: \(error)")
            return nil
        }
    }

    /// 새 키워드 저장 (중복 시 timestamp만 업데이트)
    func saveKeyword(_ keyword: String) {
        realmQueue.async { [weak self] in
            guard let realm = self?.getRealm() else { return }
            let record = RecentSearch()
            record.keyword = keyword
            record.timestamp = LZSUtil.getCurrentTimeDate()
            do {
                try realm.write {
                    realm.add(record, update: .modified)
                }
            } catch {
                print("saveKeyword 오류: \(error)")
            }
        }
    }

    /// 최근 검색어 조회 (최대 limit개)
    func fetchRecentKeywords(limit: Int = 20) async -> [String] {
        return await withCheckedContinuation { continuation in
            realmQueue.async { [weak self] in
                autoreleasepool {
                    guard let realm = self?.getRealm() else {
                        continuation.resume(returning: [])
                        return
                    }
                    let results = realm.objects(RecentSearch.self)
                                       .sorted(byKeyPath: "timestamp", ascending: false)
                                       .prefix(limit)
                    let keywords = results.map { $0.keyword }
                    continuation.resume(returning: Array(keywords))
                }
            }
        }
    }

    /// 특정 키워드 삭제
    func deleteKeyword(_ keyword: String) {
        realmQueue.async { [weak self] in
            guard let realm = self?.getRealm(),
                  let object = realm.object(ofType: RecentSearch.self, forPrimaryKey: keyword)
            else { return }
            do {
                try realm.write {
                    realm.delete(object)
                }
            } catch {
                print("deleteKeyword 오류: \(error)")
            }
        }
    }

    /// 모든 키워드 삭제
    func clearAll() {
        realmQueue.async { [weak self] in
            guard let realm = self?.getRealm() else { return }
            do {
                try realm.write {
                    realm.delete(realm.objects(RecentSearch.self))
                }
            } catch {
                print("clearAll 오류: \(error)")
            }
        }
    }
}
