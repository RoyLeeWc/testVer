//
//  RealmManager.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/10/25.
//

import RealmSwift
import Foundation

// MARK: - Realm 모델 정의
final class LocalizedString: Object {
    @objc dynamic var id: String = ""      // 예: "greeting_en"
    @objc dynamic var value: String = ""   // 예: "Hello"
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

enum LocalizedStringsError: Error {
    case invalidJsonString
    case invalidJsonFormat
}

final class LocalizedStringManager {
    static let shared = LocalizedStringManager()
    let realm: Realm?
    
    private init() {
        do {
            realm = try? Realm()
        } catch {
            print("Realm 초기화 오류: \(error)")
            realm = nil
        }
    }
    
    /// JSON 문자열을 파싱하여 Realm에 저장하는 메서드
    /// - Parameter jsonString: JSON 문자열 (키: value 형태, 예: "greeting_en": "Hello")
    func importLocalizedStrings(from jsonString: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // 1. JSON 문자열을 Data로 변환
        guard let jsonData = jsonString.data(using: .utf8) else {
            completion(.failure(LocalizedStringsError.invalidJsonString))
            return
        }
        
        do {
            // 2. JSON 데이터를 [String: String] 형태로 파싱
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            guard let jsonDictionary = jsonObject as? [String: String] else {
                completion(.failure(LocalizedStringsError.invalidJsonFormat))
                return
            }
            
            let realm = try Realm()
            
            try realm.write {
                // 각 key-value 쌍을 순회하며 Realm에 저장(업데이트)
                for (jsonKey, value) in jsonDictionary {
                    let localizedString = LocalizedString()
                    localizedString.id = jsonKey
                    localizedString.value = value
                    realm.add(localizedString, update: .modified)
                }
            }
            print("Realm에 JSON 데이터 저장 완료")
            // write 작업이 완료되면 성공 결과를 전달
            completion(.success(()))
            
        } catch {
            print("Error: \(error)")
            completion(.failure(error))
        }
    }
    
    /// 전체 LocalizedString 데이터를 조회하는 메서드
    func fetchAllLocalizedStrings() -> Results<LocalizedString>? {
        let realm = try? Realm()
        return realm?.objects(LocalizedString.self)
    }
    
    /// 특정 프라이머리 키에 해당하는 데이터를 조회하는 메서드
    /// - Parameter id: JSON 키, 예: "greeting_en"
    func fetchLocalizedString(for id: String) -> String? {
        let realm = try? Realm()
        return realm?.object(ofType: LocalizedString.self, forPrimaryKey: id)?.value
    }
    
    func fetchLocalizedString(withLangCode:String, for id: String) -> String? {
        let realm = try? Realm()
        return realm?.object(ofType: LocalizedString.self, forPrimaryKey: id+"_\(withLangCode)")?.value
    }
    
    /// 특정 프라이머리 키에 해당하는 데이터를 업데이트하는 메서드
    func updateLocalizedString(for id: String, with newValue: String) {
        do {
            let realm = try? Realm()
            try realm?.write {
                if let localizedString = realm?.object(ofType: LocalizedString.self, forPrimaryKey: id) {
                    localizedString.value = newValue
                } else {
                    let localizedString = LocalizedString()
                    localizedString.id = id
                    localizedString.value = newValue
                    realm?.add(localizedString, update: .modified)
                }
            }
        } catch {
            print("업데이트 실패 ")
        }
    }
    
}
