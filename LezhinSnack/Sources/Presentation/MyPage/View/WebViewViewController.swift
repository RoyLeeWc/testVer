//
//  WebViewViewController.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/12/25.
//


import UIKit
import SnapKit
import Combine
@preconcurrency import WebKit
import SafariServices

final class WebViewViewController: UIViewController, ChildNavigationBarPresentable {
    
    let childNavigationBar = ChildNavigationBar()
    
    lazy var balconyWebView = LZSUtil.makeBalconyWebView()
    
    
    let viewModel: InAppPurchaseViewModel
    
    init?(viewModel: InAppPurchaseViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupUI()
        
    }
    
    func setupUI() {
        setupChildNavigationBar()
        childNavigationBar.titleLabel.text = "앱바_충전소_타이틀".localized
        
        childNavigationBar.delegate = self
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        view.backgroundColor = UIColor(.backgroundDefault)
        
        
        
        view.addSubview(balconyWebView)
        balconyWebView.snp.makeConstraints { make in
            make.top.equalTo(childNavigationBar.snp.bottom)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        balconyWebView.uiDelegate = self
        balconyWebView.navigationDelegate = self
        
        guard let request = LZSUtil.balconyTypeUrl(urlString: "https://dev.bomtoon.com/shop") else { return }
        
        balconyWebView.load(request)
        
        balconyWebView.configuration.userContentController.add(WebViewMemoryLeakAvoider(delegate: self), name: "jsRequestPushKey")
        balconyWebView.configuration.userContentController.add(WebViewMemoryLeakAvoider(delegate: self), name: "jsBrowserAction")
        balconyWebView.configuration.userContentController.add(WebViewMemoryLeakAvoider(delegate: self), name: "jsRequestAppversion")
        balconyWebView.configuration.userContentController.add(WebViewMemoryLeakAvoider(delegate: self), name: "jsSettings")
        balconyWebView.configuration.userContentController.add(WebViewMemoryLeakAvoider(delegate: self), name: "jsApplePurchase")
    }
    
    
}



extension WebViewViewController: ChildNavigationBarDelegate {
    func childNavigationBarDidTapBack(_ navigationBar: ChildNavigationBar) {
        navigationController?.popViewController(animated: true)
    }
    
     
}

extension WebViewViewController: UIGestureRecognizerDelegate {
    
}

extension WebViewViewController: WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler, SFSafariViewControllerDelegate {

    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Swift.Void) {
        let completionHandlerWrapper = UIAlertController.CompletionHandlerWrapper(completionHandler: { _ in completionHandler()}, defaultValue: false)
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let otherAction = UIAlertAction(title: "확인", style: .default) { _ in
            completionHandlerWrapper.respondHandler(true)
        }
        alert.addAction(otherAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let completionHandlerWrapper = UIAlertController.CompletionHandlerWrapper(completionHandler: completionHandler, defaultValue: false)
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in completionHandlerWrapper.respondHandler(false) }
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in completionHandlerWrapper.respondHandler(true) }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //#MARK: 자바스크립트 브릿지
    func userContentController( _ userContentController: WKUserContentController, didReceive message: WKScriptMessage ) {
        printX("script bridge : \(message.name)")
        
        switch message.name {
        case "callbackHandler":
            printX(message.body)
        case "jsSettings":
            printX(message.body)
        case "jsConfirm":
            printX(message.body)
        case "jsOpenBrowser":
            printX(message.body)
        case "jsBrowserAction":
            printX(message.body)
        case "jsSetUserInfo":
            printX(message.body)
        case "jsApplePurchase":
            guard let messageString = message.body as? String else { return }
            viewModel.jsApplePurchase(purchaseStringData: messageString)
        default:
            break
        }
    }
    
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation! ) {
        if let url = webView.url?.absoluteString {
            printX("url = \(url)")
        }
    }
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        guard let url = navigationAction.request.url else { return nil }
        UIApplication.shared.open(url)
        return nil
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        let vc = PurchaseSuccessViewController()
//        self.navigationController?.pushHidesBottomBarViewController(vc)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let url = webView.url?.absoluteString {
            print("url4 = \(url)")
            //공유하기에서 웹페이지로 이동하는 것 막기
            if url.contains("blob:") {
                decisionHandler(.cancel)
                return
            }
        }
        if let urlResponse = navigationResponse.response as? HTTPURLResponse,
           let url = urlResponse.url,
           let allHeaderFields = urlResponse.allHeaderFields as? [String: String] {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: allHeaderFields, for: url)
            HTTPCookieStorage.shared.setCookies(cookies , for: urlResponse.url!, mainDocumentURL: nil)
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        _ = navigationAction.request.url!.absoluteString
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        // 웹킷 엔진에서, 랜더링 도중 웹뷰의 프로세스가 종료 되었을때 이 메소드를 호출
        webView.reload()
    }
    
    @available(iOS 14.5, *)
    func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        printX("Download Progress : \(download.progress)")
    }
    
    @available(iOS 14.5, *)
    func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        printX("Download Complete")
    }
}

