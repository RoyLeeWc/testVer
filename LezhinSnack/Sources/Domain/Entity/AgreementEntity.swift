//
//  AgreementEntity.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/10/25.
//

import Foundation


struct AgreementEntity: Hashable {
    
    let id: UUID
    let title: String
    let subtitle: String?
    var isChecked: Bool
    let agreementType: AgreementType

    init(id: UUID = UUID(),
         title: String,
         subtitle: String? = nil,
         isChecked: Bool = false,
         agreementType: AgreementType
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.isChecked = isChecked
        self.agreementType = agreementType
    }

    // Only id is used for Hashable & Equatable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: AgreementEntity, rhs: AgreementEntity) -> Bool {
        return lhs.id == rhs.id
    }
}
