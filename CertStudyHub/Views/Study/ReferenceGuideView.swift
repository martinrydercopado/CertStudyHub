import SwiftUI
import WebKit

// MARK: - Reference Guide View

struct ReferenceGuideView: View {
    let url: URL
    let certConfig: CertConfig

    var body: some View {
        WebViewWrapper(url: url)
            .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Platform-specific WebView Wrappers

#if os(iOS)
private struct WebViewWrapper: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .systemBackground
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}
#elseif os(macOS)
private struct WebViewWrapper: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {}
}
#endif
