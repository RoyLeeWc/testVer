//
//  UIDevice+Extension.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/9/25.
//
import UIKit

extension UIDevice {
    static var isiPad: Bool { current.userInterfaceIdiom == .pad }
    static var isiPhone: Bool { current.userInterfaceIdiom == .phone }
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
}
