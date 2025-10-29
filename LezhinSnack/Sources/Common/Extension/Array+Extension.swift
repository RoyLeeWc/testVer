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
    
    /// 조건에 따라 배열을 두 파티션으로 분리
    func partitioned(by belongsInFirst: (Element) -> Bool) -> ([Element], [Element]) {
        var first: [Element] = []
        var second: [Element] = []
        first.reserveCapacity(self.count / 2)
        second.reserveCapacity(self.count / 2)
        
        for element in self {
            if belongsInFirst(element) {
                first.append(element)
            } else {
                second.append(element)
            }
        }
        return (first, second)
    }
}


// 사용 예시
//let value = array[safe: 3] // index 초과 시 nil 반환


extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
