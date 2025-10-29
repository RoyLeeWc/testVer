//
//  AgreementDetailWebViewController.swift
//  LezhinSnack
//
//  Created by lwc on 9/30/25.
//

import UIKit
import WebKit
import SnapKit

final class AgreementDetailWebViewController: UIViewController, ChildNavigationBarPresentable {

    // MARK: - Inputs
    private let pageTitle: String
    private let url: URL

    // MARK: - UI
    let childNavigationBar = ChildNavigationBar()
    private let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    private let activity = UIActivityIndicatorView(style: .medium)

    // MARK: - Init
    init(title: String, url: URL) {
        self.pageTitle = title
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(.backgroundDefault)
        setupUI()
        load()
    }

    private func setupUI() {
        // 1) 앱바(ChildNavigationBar) 제목 ← [요구 1번]
        setupChildNavigationBar()
        childNavigationBar.delegate = self
        childNavigationBar.titleLabel.text = pageTitle

        // 2) 웹뷰 영역 ← [요구 2번]
        view.addSubview(webView)
        webView.navigationDelegate = self
        webView.backgroundColor = UIColor(.backgroundDefault)
        webView.isOpaque = false
        webView.snp.makeConstraints { make in
            make.top.equalTo(childNavigationBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

        view.addSubview(activity)
        activity.hidesWhenStopped = true
        activity.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func load() {
        var req = URLRequest(url: url)
        // 공통 User-Agent/헤더 세팅은 NetworkService가 아니라 시스템 웹뷰라 여기선 최소화(커스텀 금지 요청 반영)
        webView.load(req)
    }
}

// MARK: - Back
extension AgreementDetailWebViewController: ChildNavigationBarDelegate {
    func childNavigationBarDidTapBack(_ navigationBar: ChildNavigationBar) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate
extension AgreementDetailWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) { activity.startAnimating() }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { activity.stopAnimating() }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { activity.stopAnimating() }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) { activity.stopAnimating() }
}
