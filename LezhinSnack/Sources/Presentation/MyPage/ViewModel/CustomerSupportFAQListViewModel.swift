//
//  CustomerSupportFAQListViewModel.swift
//  LezhinSnack
//
//  Created by lwc on 10/20/25.
//

import Combine

final class CustomerSupportFAQListViewModel {
    @Published private(set) var items: [FaqEntity] = []
    @Published private(set) var errorMessage: String?

    // ✅ 프리페치 데이터로만 사용하는 초기화
    init(items: [FaqEntity]) {
        self.items = items

    }

//    }
    // (기존 통신 기반 초기화는 필요 시 유지)
    // private let useCase: FAQUseCaseProtocol?
    // private let categoryId: Int?
    // init(useCase: FAQUseCaseProtocol, categoryId: Int) { ... }
    // func fetch() { ... } // 지금 플로우에서는 호출 안 함
}

