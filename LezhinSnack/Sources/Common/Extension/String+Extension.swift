//
//  String+Extension.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/18/25.
//

import SwiftyUserDefaults
import Foundation


extension String {
    /// Realm에 저장된 localized string을 가져오며, 없을 경우 원본 문자열을 반환합니다.
    var dynamicLocalized: String {
        if Defaults.showLocalStringKey {
            return self + "_\(Defaults.currentSetLanguageCode)"
        } else {
            return LocalizedStringManager.shared.fetchLocalizedString(withLangCode: Defaults.currentSetLanguageCode, for: self) ?? self
        }
    }
    
    var localized: String {
        return NSLocalizedString(self, tableName: "Localizable", bundle: Bundle.main, value: self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments)
    }
    
    /// 문자열을 지정한 Decodable 타입으로 디코딩합니다.
    func decode<T: Decodable>(to type: T.Type, using decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = self.data(using: .utf8) else { return nil }
        return try? decoder.decode(type, from: data)
    }
    
}
