//
//  Resolver+Extension.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/10/25.
//


import Swinject

extension Resolver {
    func resolveOrFail<T>(_ serviceType: T.Type, file: StaticString = #file, line: UInt = #line) -> T {
        guard let service = self.resolve(serviceType) else {
            fatalError("Could not resolve \(serviceType) at \(file):\(line)")
        }
        return service
    }
}
