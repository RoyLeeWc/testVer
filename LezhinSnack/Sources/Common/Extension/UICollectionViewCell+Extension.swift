//
//  UICollectionViewCell+Extension.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/14/25.
//

import UIKit

public protocol Nameable {
    static var typeName: String { get }
}

public extension Nameable {
    static var typeName: String {
        String(describing: self)
    }
}

public protocol CellReuseIdentifiable: Nameable {
    static var reuseIdentifier: String { get }
}

public extension CellReuseIdentifiable {
    static var reuseIdentifier: String {
        self.typeName
    }
}

extension UICollectionReusableView: CellReuseIdentifiable {}
extension UITableViewCell: CellReuseIdentifiable {}

public extension UICollectionView {
    
    func register<T: UICollectionViewCell>(_ cellClass: T.Type) where T: CellReuseIdentifiable {
        register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    func register<T: UICollectionReusableView>(_ viewClass: T.Type, forSupplementaryViewOfKind: String) where T: CellReuseIdentifiable {
        register(
            T.self,
            forSupplementaryViewOfKind: forSupplementaryViewOfKind,
            withReuseIdentifier: T.reuseIdentifier
        )
    }
}
