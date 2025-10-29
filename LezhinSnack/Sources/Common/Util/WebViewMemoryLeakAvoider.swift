//
//  WebViewMemoryLeakAvoider.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/19/25.
//


import Foundation
import WebKit


final class WebViewMemoryLeakAvoider:  NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?
    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(userContentController, didReceive: message)
    }
}
