//
//  LZSnackHTMLView.swift
//  LezhinSnack
//
//  Created by lwc on 10/20/25.
//

import UIKit
import WebKit
import SnapKit

final class LZSnackHTMLView: UIView, WKNavigationDelegate {
    private let webView: WKWebView = {
        let cfg = WKWebViewConfiguration()
        cfg.allowsInlineMediaPlayback = true
        cfg.defaultWebpagePreferences.preferredContentMode = .mobile
        let wv = WKWebView(frame: .zero, configuration: cfg)
        wv.isOpaque = false
        wv.backgroundColor = .clear
        wv.scrollView.backgroundColor = .clear
        wv.scrollView.isScrollEnabled = false     // 상위 스크롤뷰 사용
        wv.scrollView.bounces = false
        wv.scrollView.contentInsetAdjustmentBehavior = .never
        return wv
    }()

    private var heightConstraint: Constraint?
    var onHeightChange: ((CGFloat) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        addSubview(webView)
        webView.navigationDelegate = self
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            heightConstraint = make.height.equalTo(1).constraint // 내용 로드 후 갱신
        }
    }

    /// HTML을 로드한다. 서버에서 내려온 `contents` 그대로 넣어주면 됨.
    func load(html raw: String, baseURL: URL? = nil) {
        let css = """
        <meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
        <style>
          html,body { margin:0; padding:0; background:transparent; }
          body { font-family: -apple-system, BlinkMacSystemFont, Pretendard, Helvetica, Arial, sans-serif;
                 font-size: 16px; line-height: 1.6; color: #FFFFFF; }
          p { margin: 0 0 12px 0; }
          img, video, iframe { max-width: 100%; height: auto; }
          a { color: #E80023; text-decoration: none; } /* 브랜드 색 필요시 변경 */
          ul,ol { padding-left: 20px; }
          table { width: 100%; border-collapse: collapse; }
          hr { border: 0; height: 1px; background: rgba(255,255,255,0.08); }
          * { -webkit-touch-callout:none; -webkit-user-select:none; user-select:none; }
        </style>
        """
        let html = """
        <!doctype html><html><head>\(css)</head><body>\(raw)</body></html>
        """
        webView.loadHTMLString(html, baseURL: baseURL)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //  높이 측정 → 제약 갱신
        webView.evaluateJavaScript("document.body.scrollHeight") { [weak self] result, _ in
            guard let self else { return }
            let h: CGFloat
            if let n = result as? NSNumber { h = CGFloat(truncating: n) }
            else if let d = result as? Double { h = CGFloat(d) }
            else { h = 1 }
            self.heightConstraint?.update(offset: ceil(h))
            self.onHeightChange?(ceil(h))
            // 이미지가 늦게 로드될 수 있으니 한 번 더 갱신(지연)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                webView.evaluateJavaScript("document.body.scrollHeight") { result, _ in
                    if let n = result as? NSNumber {
                        let hh = CGFloat(truncating: n).rounded(.up)
                        self.heightConstraint?.update(offset: hh)
                        self.onHeightChange?(hh)
                    }
                }
            }
        }
    }

    // 외부로 나가는 링크는 Safari로 열기
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated,
           let url = navigationAction.request.url {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
