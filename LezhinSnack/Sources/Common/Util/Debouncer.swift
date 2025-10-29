//
//  Debouncer.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/9/25.
//


import Foundation

final class Debouncer {
    private var workItem: DispatchWorkItem?
    private let delay: TimeInterval
    
    init(delay: TimeInterval = 0.5) {
        self.delay = delay
    }
    
    func run(action: @escaping () -> Void) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        workItem?.cancel()
        
        let workItem = DispatchWorkItem(block: action)
        self.workItem = workItem
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }
}
/***
    사용 예시
    let debouncer = Debouncer(delay: 1.0)
    debounce.run {
        search(query)
    }
 */
