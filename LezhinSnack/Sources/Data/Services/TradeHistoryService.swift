//
//  TradeHistoryService.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/20/25.
//

import Foundation
import RealmSwift

// 앱 전역에서 공유할 단일 Realm 전용 직렬 큐
final class RealmQueue {
    static let shared = RealmQueue()
    private init() {}
    
    // 모든 서비스가 이 큐를 통해 Realm에 접근하도록 함
    let queue = DispatchQueue(label: "com.lezhin.app.realmQueue")
}

// Realm 모델
final class TradeMapping: Object {
    @objc dynamic var productID: String = ""
    @objc dynamic var tradeID: String = ""
    @objc dynamic var createdAt: Date = Date()    // 삽입 시점을 기록하는 필드

    override static func primaryKey() -> String? {
        return "tradeID"
    }
}

// TradeHistoryService (리팩토링 및 최신 tradeID 조회 기능 포함)
final class TradeHistoryService {
    // 앱 전체에서 공유하는 Realm 전용 직렬 큐
    private let realmQueue = RealmQueue.shared.queue

    // MARK: - 쓰기(매핑 추가)
    func addMapping(productID: String, tradeID: String) async {
        realmQueue.async {
            do {
                let realm = try Realm()
                // 이미 동일 tradeID가 있으면 추가하지 않음
                if realm.object(ofType: TradeMapping.self, forPrimaryKey: tradeID) != nil {
                    return
                }
                
                let mapping = TradeMapping()
                mapping.productID = productID
                mapping.tradeID = tradeID
                // createdAt은 기본값으로 Date()가 설정됨
                
                try realm.write {
                    realm.add(mapping)
                }
            } catch {
                print("Realm 매핑 추가 오류: \(error)")
                return
            }
        }
    }
    
    // MARK: - 쓰기(매핑 삭제)
    func removeMapping(productID: String, tradeID: String) async {
        realmQueue.async {
            do {
                let realm = try Realm()
                if let mapping = realm.object(
                    ofType: TradeMapping.self,
                    forPrimaryKey: tradeID
                ), mapping.productID == productID {
                    try realm.write {
                        realm.delete(mapping)
                    }
                }
            } catch {
                print("Realm 매핑 삭제 오류: \(error)")
                return
            }
        }
    }
    
    // MARK: - 쓰기(특정 제품 코드의 모든 매핑 삭제)
    func removeAllMappings(for productID: String) async {
        realmQueue.async {
            do {
                let realm = try Realm()
                let mappings = realm.objects(TradeMapping.self)
                                    .filter("productID == %@", productID)
                try realm.write {
                    realm.delete(mappings)
                }
            } catch {
                print("모든 매핑 삭제 오류: \(error)")
                return
            }
        }
    }
    
    // MARK: - 읽기(특정 제품 코드에 매핑된 모든 tradeID 조회)
    func getTradeIDs(for productID: String) async -> [String] {
        return await withCheckedContinuation { continuation in
            realmQueue.async {
                do {
                    let realm = try Realm()
                    let mappings = realm.objects(TradeMapping.self)
                                        .filter("productID == %@", productID)
                    let tradeIDs = mappings.map { $0.tradeID }
                    continuation.resume(returning: Array(tradeIDs))
                } catch {
                    print("Realm 매핑 조회 오류 (getTradeIDs): \(error)")
                    continuation.resume(returning: [])
                }
            }
        }
    }
    
    // MARK: - 읽기(tradeID에 해당하는 제품 코드 조회)
    func getProductID(for tradeID: String) async -> String? {
        return await withCheckedContinuation { continuation in
            realmQueue.async {
                do {
                    let realm = try Realm()
                    if let mapping = realm.object(ofType: TradeMapping.self, forPrimaryKey: tradeID) {
                        continuation.resume(returning: mapping.productID)
                    } else {
                        continuation.resume(returning: nil)
                    }
                } catch {
                    print("Realm 매핑 조회 오류 (getproductID): \(error)")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    // MARK: - 읽기(특정 제품 코드의 최신 tradeID 조회)
    func getLatestTradeID(for productID: String) async -> String? {
        return await withCheckedContinuation { continuation in
            realmQueue.async {
                do {
                    let realm = try Realm()
                    // productID가 일치하는 매핑을 createdAt 내림차순으로 정렬
                    let results = realm.objects(TradeMapping.self)
                                        .filter("productID == %@", productID)
                                        .sorted(byKeyPath: "createdAt", ascending: false)
                    // 첫 번째 결과가 최신
                    if let latest = results.first {
                        continuation.resume(returning: latest.tradeID)
                    } else {
                        continuation.resume(returning: nil)
                    }
                } catch {
                    print("Realm 최신 tradeID 조회 오류: \(error)")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
