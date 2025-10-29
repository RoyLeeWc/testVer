//
//  Data+Extension.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/9/25.
//

import Foundation

extension Data {
    func decoded<T: Decodable>(to type: T.Type) -> T? {
        try? JSONDecoder().decode(T.self, from: self)
    }
}


/**
     사용예시
     
     if let user = data.decoded(to: User.self) {
         print(user.name)
     }
 */
