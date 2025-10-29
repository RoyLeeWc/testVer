//
//  Array+Extension.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/9/25.
//


extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}


// 사용 예시
//let value = array[safe: 3] // index 초과 시 nil 반환
