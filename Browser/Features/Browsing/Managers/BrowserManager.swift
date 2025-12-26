//
//  BrowserManager.swift
//  Browser
//

import SwiftData
import SwiftUI
import UIKit
import WebKit

@Observable
@MainActor
final class BrowserManager: NSObject {
    var context: ModelContext?
    weak var appSettings: AppSettings?
    
    let webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let view = WKWebView(frame: .zero, configuration: config)
        view.allowsBackForwardNavigationGestures = true
        view.allowsLinkPreview = true
        view.scrollView.delaysContentTouches = false
        return view
    }()

    var urlString: String = ""
    var isLoading: Bool = false
    var estimatedProgress: Double = 0

    var canGoBack: Bool = false
    var canGoForward: Bool = false
    
    var addressBarIsActive: Bool = false
    
    var isPresentingHistorySheet: Bool = false
    var isPresentingPageMenuSheet: Bool = false
    var isPresentingSettingsSheet: Bool = false

    private var hasLoadedHome: Bool = false
    
    private var lastRecordedHistoryURL: URL?
    private var lastRecordedHistoryAt: Date?
    
    // Used to throttle gesture workaround while scrolling.
    private var lastGestureWorkaroundApplyTime: TimeInterval = 0

    override init() {
        super.init()

        webView.navigationDelegate = self
        if #available(iOS 26.0, *) {
            webView.scrollView.delegate = self
            applyWebViewGestureWorkarounds(force: true)
        }

        // KVO for loading/progress/url + canGoBack/canGoForward updates
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.url), options: [.new], context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: [.new], context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: [.new], context: nil)
    }

    @MainActor
    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.url))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.isLoading))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }

    func load(url: URL) {
        webView.load(URLRequest(url: url))
        updateNavigationState()
    }

    func loadInitial(url: URL) {
        load(url: url)
    }

    /// Loads the initial "home" page once per app launch.
    /// SwiftUI view lifecycles can trigger `.task` multiple times, which would create a duplicate history entry.
    func loadHomeIfNeeded(url: URL) {
        guard !hasLoadedHome else { return }
        hasLoadedHome = true
        load(url: url)
    }

    /// Converts user-entered text into a loadable URL, falling back to the default search engine when needed.
    func urlFromUserInput(_ input: String) -> URL {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let defaultSearchEngine = appSettings?.defaultSearchEngine ?? .google
        
        guard !trimmed.isEmpty else {
            return defaultSearchEngine.searchURL(for: "")
        }

        // If the user provided a full URL with a scheme, trust it.
        if let directURL = URL(string: trimmed), directURL.scheme != nil {
            return directURL
        }

        // If the text looks like a hostname (e.g., example.com), prepend https and try again.
        if let httpsURL = URL(string: "https://\(trimmed)"),
           let host = URLComponents(url: httpsURL, resolvingAgainstBaseURL: false)?.host,
           isLikelyHostname(host) {
            return httpsURL
        }

        // Fallback to the default search engine query.
        return defaultSearchEngine.searchURL(for: trimmed)
    }

    private func isLikelyHostname(_ host: String) -> Bool {
        guard !host.isEmpty, !host.contains(where: { $0.isWhitespace }) else { return false }
        return host.contains(".")
    }
    
    private func isUserVisibleHistoryURL(_ url: URL) -> Bool {
        // Filter out WebKit internal pages.
        if url.absoluteString == "about:blank" { return false }
        if url.scheme == "about" { return false }
        return true
    }
    
    private func shouldRecordHistoryVisit(for url: URL, now: Date) -> Bool {
        guard isUserVisibleHistoryURL(url) else { return false }
        
        // WKWebView can call `didFinish` multiple times for the same URL quickly (iframes / redirects / reflows).
        if let lastURL = lastRecordedHistoryURL,
           let lastAt = lastRecordedHistoryAt,
           lastURL == url,
           now.timeIntervalSince(lastAt) < 1.0 {
            return false
        }
        
        return true
    }
    
    private func resolvePageTitle(for webView: WKWebView, url: URL) async -> String {
        // Give WebKit a bit to update webView.title after didFinish.
        try? await Task.sleep(for: .milliseconds(150))
        
        let existing = webView.title?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let existing, !existing.isEmpty, existing != url.absoluteString {
            return existing
        }
        
        // fallback: read document.title directly
        let jsTitle: String? = await withCheckedContinuation { continuation in
            webView.evaluateJavaScript("document.title") { result, _ in
                continuation.resume(returning: result as? String)
            }
        }
        
        let trimmedJSTitle = jsTitle?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let trimmedJSTitle, !trimmedJSTitle.isEmpty {
            return trimmedJSTitle
        }
        
        return url.host ?? url.absoluteString
    }
    
    private func recordHistoryVisitIfNeeded() {
        guard let context else { return }
        guard let url = webView.url else { return }
        
        let now = Date()
        guard shouldRecordHistoryVisit(for: url, now: now) else { return }

        let capturedURL = url
        let capturedAt = now

        Task { @MainActor in
            // if the user has already navigated away, don't risk storing a mismatched title.
            guard self.webView.url == capturedURL else { return }

            let title = await resolvePageTitle(for: self.webView, url: capturedURL)

            guard self.webView.url == capturedURL else { return }

            let entry = HistoryEntry(title: title, url: capturedURL, date: capturedAt)
            context.insert(entry)

            self.lastRecordedHistoryURL = capturedURL
            self.lastRecordedHistoryAt = capturedAt
        }
    }

    func refreshPage() {
        webView.reload()
        updateNavigationState()
    }

    func updateNavigationState() {
        // WKWebView can report canGoBack = true due to an internal about:blank entry or duplicate loads.
        // Derive a "real" back/forward state from the back-forward list and ignore non-user-visible items.
        let currentURL = webView.url

        let backList = webView.backForwardList.backList
        let forwardList = webView.backForwardList.forwardList

        let hasRealBack = backList.contains { item in
            guard isUserVisibleHistoryURL(item.url) else { return false }
            if let currentURL, item.url == currentURL { return false }
            return true
        }

        let hasRealForward = forwardList.contains { item in
            guard isUserVisibleHistoryURL(item.url) else { return false }
            if let currentURL, item.url == currentURL { return false }
            return true
        }

        canGoBack = webView.canGoBack && hasRealBack
        canGoForward = webView.canGoForward && hasRealForward
    }

    /// Prevents an OS-level crash in UIKit gesture delay handling that can be triggered by WKWebView
    /// during taps/scrolls (`-[__NSArrayM insertObject:atIndex:]: object cannot be nil`).
    private func applyWebViewGestureWorkarounds(force: Bool = false) {
        guard #available(iOS 26.0, *) else { return }

        // Throttle: can be called frequently while scrolling.
        let now = Date.timeIntervalSinceReferenceDate
        if !force, (now - lastGestureWorkaroundApplyTime) < 0.2 { return }
        lastGestureWorkaroundApplyTime = now

        func disableDelayedTouchesRecursively(in view: UIView) {
            view.gestureRecognizers?.forEach {
                $0.delaysTouchesBegan = false
                $0.delaysTouchesEnded = false
                $0.cancelsTouchesInView = false
            }
            view.subviews.forEach { disableDelayedTouchesRecursively(in: $0) }
        }

        disableDelayedTouchesRecursively(in: webView)

        // Extra hardening for scroll gestures
        webView.scrollView.panGestureRecognizer.delaysTouchesBegan = false
        webView.scrollView.panGestureRecognizer.delaysTouchesEnded = false
        webView.scrollView.panGestureRecognizer.cancelsTouchesInView = false
        webView.scrollView.pinchGestureRecognizer?.delaysTouchesBegan = false
        webView.scrollView.pinchGestureRecognizer?.delaysTouchesEnded = false
        webView.scrollView.pinchGestureRecognizer?.cancelsTouchesInView = false

        // Retry on the next runloop. WKWebView often attaches recognizers lazily.
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            disableDelayedTouchesRecursively(in: self.webView)
            self.webView.scrollView.panGestureRecognizer.delaysTouchesBegan = false
            self.webView.scrollView.panGestureRecognizer.delaysTouchesEnded = false
            self.webView.scrollView.panGestureRecognizer.cancelsTouchesInView = false
            self.webView.scrollView.pinchGestureRecognizer?.delaysTouchesBegan = false
            self.webView.scrollView.pinchGestureRecognizer?.delaysTouchesEnded = false
            self.webView.scrollView.pinchGestureRecognizer?.cancelsTouchesInView = false
        }
    }

    func handle(_ action: BrowserToolbarItem.Action) {
        switch action {
        case .goBack:
            guard webView.canGoBack else { return }
            webView.goBack()

        case .goForward:
            guard webView.canGoForward else { return }
            webView.goForward()

        case .newTab:
            print("Create new tab")

        case .openMenu:
            isPresentingPageMenuSheet.toggle()

        case .showTabs:
            print("Show tabs")
        }

        updateNavigationState()
    }

    func isToolbarButtonDisabled(_ item: BrowserToolbarItem) -> Bool {
        switch item {
        case .back: return !canGoBack
        case .forward: return !canGoForward
        case .newTab, .menu, .tabs: return false
        }
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        switch keyPath {
        case #keyPath(WKWebView.url):
            urlString = webView.url?.absoluteString ?? ""
            updateNavigationState()

        case #keyPath(WKWebView.isLoading):
            isLoading = webView.isLoading
            updateNavigationState()

        case #keyPath(WKWebView.estimatedProgress):
            estimatedProgress = webView.estimatedProgress

        default:
            break
        }
    }
}

extension BrowserManager: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        applyWebViewGestureWorkarounds(force: true)
        updateNavigationState()
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        applyWebViewGestureWorkarounds(force: true)
        updateNavigationState()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        applyWebViewGestureWorkarounds(force: true)
        updateNavigationState()
        recordHistoryVisitIfNeeded()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        applyWebViewGestureWorkarounds(force: true)
        updateNavigationState()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        applyWebViewGestureWorkarounds(force: true)
        updateNavigationState()
    }
}

extension BrowserManager: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        applyWebViewGestureWorkarounds(force: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        applyWebViewGestureWorkarounds()
    }
}
