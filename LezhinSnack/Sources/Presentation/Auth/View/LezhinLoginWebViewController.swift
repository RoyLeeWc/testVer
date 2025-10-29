//
//  LezhinLoginWebViewController.swift
//  LezhinSnack
//
//  Created by lwc on 10/16/25.
//

import UIKit
import WebKit
import SafariServices

/// 레진 로그인 전용 웹뷰
final class LezhinLoginWebViewController: UIViewController {

    // MARK: - Public API
    enum Environment {
        case dev
        case prod
        
        var loginURL: URL {
            switch self {
            case .dev:
                return URL(string: "https://mirror-www.lezhin.com/ko/snack/login")!
            case .prod:
                return URL(string: "https://www.lezhin.com/ko/snack/login")!
            }
        }
        
        var hostAllowList: [String] {
            switch self {
            case .dev:
                return ["mirror-www.lezhin.com"]
            case .prod:
                return ["www.lezhin.com"]
            }
        }
    }
    
    /// 로그인 성공(token 수신) 시 콜백
    var onLoginSuccess: ((String) -> Void)?
    /// 유저가 닫기/취소했을 때 콜백(필요 시)
    var onCancel: (() -> Void)?
    
    // MARK: - Private
    private let environment: Environment
    private var webView: WKWebView!
    private let progressView = UIProgressView(progressViewStyle: .bar)
    private var kvoContext = 0
    
    /// 헤더 키 (스펙)
    private enum HeaderKey {
        static let snackVersion  = "LZ-SNACK-VERSION"
        static let snackPlatform = "LZ-SNACK-PLATFORM"
    }
    /// 헤더 값
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    }
    private let platform = "ios"
    
    // snack-bridge 스킴/호스트(스펙)
    private let bridgeScheme   = "snack-bridge"
    private let bridgeLogin    = "lezhin-login"
    private let bridgeClose    = "lezhin-close"
    
    // 로그인 브리지 중복 호출 방지
    private var didDeliverLogin = false
    
    // ✅ 테스트용 닫기 버튼
    private lazy var closeButton: UIButton = {
        let b = UIButton(type: .system)
        if #available(iOS 13.0, *) {
            b.setImage(UIImage(systemName: "xmark"), for: .normal)
        } else {
            b.setTitle("닫기", for: .normal)
        }
        b.tintColor = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        b.layer.cornerRadius = 16
        b.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        b.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    init(environment: Environment = .dev) {
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    deinit {
        webView?.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: &kvoContext)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(.backgroundDefault)
        
        // 1) 쿠키/스토리지 초기화(요구사항) — 세션 격리를 위해 비영구 스토어 사용
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent() // 매 진입 시 깨끗한 세션
        
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self                 // target=_blank 처리용
        webView.allowsBackForwardNavigationGestures = true
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Progress bar
        progressView.trackTintColor = UIColor(.white)
        progressView.tintColor = UIColor(.brandRed)
        view.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: [.new], context: &kvoContext)
        
        // ✅ 닫기 버튼(테스트용)
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        view.bringSubviewToFront(closeButton)
        
        // 2) 첫 요청에 헤더 2종 주입해서 로드 (스펙)
        loadInitialRequest()
    }
    
    // MARK: - Helpers
    private func loadInitialRequest() {
        var req = URLRequest(url: environment.loginURL)
        req.cachePolicy = .reloadIgnoringLocalCacheData
        req.setValue(appVersion, forHTTPHeaderField: HeaderKey.snackVersion)
        req.setValue(platform,   forHTTPHeaderField: HeaderKey.snackPlatform)
        webView.load(req)
    }
    
    // 외부 브라우저로 열어야 하는 URL (스펙)
    private func shouldOpenExternally(_ url: URL) -> Bool {
        guard let host = url.host else { return false }
        let isAllowedHost = environment.hostAllowList.contains(host)
        guard isAllowedHost else { return false }
        
        let path = url.path.lowercased()
        // 약관 상세보기: /ko/policy 로 시작
        if path.hasPrefix("/ko/policy") { return true }
        // 비밀번호 찾기
        if path == "/ko/login/forgot_password" { return true }
        return false
    }
    
    private func openExternally(_ url: URL) {
        let safari = SFSafariViewController(url: url)
        present(safari, animated: true)
    }
    
    // 닫기 동작(모달/푸시 둘 다 커버)
    @objc private func didTapClose() {
        onCancel?()
        if presentingViewController != nil, navigationController?.viewControllers.first == self {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    /// 신규 네비게이션에서 헤더가 없으면 GET 요청만 재작성해서 주입
    private func reloadWithHeadersIfNeeded(_ action: WKNavigationAction) -> Bool {
        let req = action.request
        // 이미 둘 다 있으면 건드리지 않음
        if req.value(forHTTPHeaderField: HeaderKey.snackVersion) != nil &&
           req.value(forHTTPHeaderField: HeaderKey.snackPlatform) != nil {
            return false
        }
        // POST 등은 그대로 두고, 메인프레임 GET만 주입
        guard (req.httpMethod ?? "GET").uppercased() == "GET",
              let url = req.url else { return false }
        
        var new = URLRequest(url: url)
        new.allowsExpensiveNetworkAccess   = req.allowsExpensiveNetworkAccess
        new.allowsConstrainedNetworkAccess = req.allowsConstrainedNetworkAccess
        new.cachePolicy                    = req.cachePolicy
        new.timeoutInterval                = req.timeoutInterval
        new.setValue(appVersion, forHTTPHeaderField: HeaderKey.snackVersion)
        new.setValue(platform,   forHTTPHeaderField: HeaderKey.snackPlatform)
        webView.load(new)
        return true
    }
    
    /// snack-bridge deep link 파싱 (login / close)
    private func handleBridgeURL(_ url: URL) -> Bool {
        guard url.scheme == bridgeScheme else { return false }
        
        switch url.host {
        case bridgeLogin:
            guard !didDeliverLogin else { return true } // 이미 전달함
            guard let comps = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return true }
            // 스펙 키: token (이전 임시키 access-token도 대비)
            let token = comps.queryItems?.first(where: { ["token", "access-token", "access_token"].contains($0.name) })?.value
            if let t = token, !t.isEmpty {
                didDeliverLogin = true
                onLoginSuccess?(t)
                didTapClose()
            }
            return true
            
        case bridgeClose:
            // 웹뷰 종료 브리지(세션 만료 등)
            didTapClose()
            return true
            
        default:
            return false
        }
    }
    
    // KVO for progress
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard context == &kvoContext, keyPath == #keyPath(WKWebView.estimatedProgress) else { return }
        progressView.isHidden = webView.estimatedProgress >= 1.0
        progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        if webView.estimatedProgress >= 1.0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                self?.progressView.isHidden = true
                self?.progressView.setProgress(0, animated: false)
            }
        }
    }
}

// MARK: - WKNavigationDelegate
extension LezhinLoginWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        // 브리지 스킴 처리
        if let url = navigationAction.request.url, handleBridgeURL(url) {
            decisionHandler(.cancel)
            return
        }
        
        // 외부 브라우저 대상
        if let url = navigationAction.request.url, shouldOpenExternally(url) {
            openExternally(url)
            decisionHandler(.cancel)
            return
        }
        
        // 메인프레임 GET 네비에 헤더 2종 주입(없을 때만)
        if navigationAction.targetFrame?.isMainFrame == true {
            if reloadWithHeadersIfNeeded(navigationAction) {
                decisionHandler(.cancel)
                return
            }
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        // 500 등 상태코드 로깅(디버깅용)
        if let http = navigationResponse.response as? HTTPURLResponse {
            printX("[WEB] \(http.statusCode) \(http.url?.absoluteString ?? "")")
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        printX("[WEB] didFail: \(error.localizedDescription)")
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        printX("[WEB] didFailProvisional: \(error.localizedDescription)")
    }
}

// MARK: - WKUIDelegate (target=_blank 등)
extension LezhinLoginWebViewController: WKUIDelegate {
    /// window.open 등 새 창 요청 처리
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else { return nil }
        
        // 새창은 전부 외부 브라우저로
        if shouldOpenExternally(url) {
            openExternally(url)
            return nil
        }
        // 그 외 새창 요청은 현재 웹뷰에서 열도록 허용
        webView.load(URLRequest(url: url))
        return nil
    }
}
