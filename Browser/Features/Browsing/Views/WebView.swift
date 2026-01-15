import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let webView: WKWebView
    var topContentInset: CGFloat = 0
    var bottomContentInset: CGFloat = 0

    func makeUIView(context: Context) -> WKWebView {
        updateContentInset(webView)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        updateContentInset(uiView)
    }
    
    private func updateContentInset(_ webView: WKWebView) {
        webView.scrollView.contentInset.top = topContentInset
        webView.scrollView.scrollIndicatorInsets.top = topContentInset
        webView.scrollView.contentInset.bottom = bottomContentInset
        webView.scrollView.scrollIndicatorInsets.bottom = bottomContentInset
    }
}
