//
//  CompletionHandlerWrapper.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/19/25.
//

import UIKit

extension UIAlertController {
    
    static func showMessage(_ message: String, buttonText : String) {
        showAlert(title: "", message: message, actions: [UIAlertAction(title: buttonText, style: .cancel, handler: nil)])
    }
    
    static func showAlert(title: String?, message: String?, actions: [UIAlertAction]) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            for action in actions {
                alert.addAction(action)
            }
            if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController, let presenting = navigationController.topViewController {
                presenting.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    class CompletionHandlerWrapper<Element> {
        private var completionHandler: ((Element) -> Void)?
        private let defaultValue: Element
        
        init(completionHandler: @escaping ((Element) -> Void), defaultValue: Element) {
            self.completionHandler = completionHandler
            self.defaultValue = defaultValue
        }
        
        func respondHandler(_ value: Element) {
            completionHandler?(value)
            completionHandler = nil
        }
        
        deinit {
            respondHandler(defaultValue)
        }
    }
}
