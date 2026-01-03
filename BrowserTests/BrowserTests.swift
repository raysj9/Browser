import Foundation
import Testing
@testable import Browser

struct SearchEngineTests {
    @Test
    func emptyQueryUsesHomepage() {
        #expect(SearchEngine.google.searchURL(for: "").absoluteString == "https://www.google.com")
        #expect(SearchEngine.bing.searchURL(for: "  ").absoluteString == "https://www.bing.com")
        #expect(SearchEngine.duckduckgo.searchURL(for: "\n").absoluteString == "https://duckduckgo.com")
    }

    @Test
    func queryIsEncodedInSearchURL() {
        let url = SearchEngine.google.searchURL(for: "swift ui")
        #expect(url.absoluteString == "https://www.google.com/search?q=swift%20ui")
    }

    @Test
    func titlesAreUserFacing() {
        #expect(SearchEngine.google.title == "Google")
        #expect(SearchEngine.bing.title == "Bing")
        #expect(SearchEngine.duckduckgo.title == "DuckDuckGo")
    }
}

struct ModelInitializationTests {
    @Test
    func browserTabStoresValues() {
        let url = URL(string: "https://example.com")!
        let tab = BrowserTab(title: "Example", url: url, isPrivate: true)
        #expect(tab.title == "Example")
        #expect(tab.url == url)
        #expect(tab.isPrivate)
    }

    @Test
    func bookmarkEntryStoresValues() {
        let url = URL(string: "https://example.com/bookmark")!
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let entry = BookmarkEntry(title: "Bookmark", url: url, date: date)
        #expect(entry.title == "Bookmark")
        #expect(entry.url == url)
        #expect(entry.date == date)
    }

    @Test
    func historyEntryStoresValues() {
        let url = URL(string: "https://example.com/history")!
        let date = Date(timeIntervalSince1970: 1_700_000_100)
        let entry = HistoryEntry(title: "History", url: url, date: date)
        #expect(entry.title == "History")
        #expect(entry.url == url)
        #expect(entry.date == date)
    }
}

struct BookmarksViewModelTests {
    @Test
    func filteredEntriesReturnsAllWhenSearchIsEmpty() {
        let viewModel = BookmarksViewModel()
        let entries = [
            BookmarkEntry(title: "OpenAI", url: URL(string: "https://openai.com")!),
            BookmarkEntry(title: "Apple", url: URL(string: "https://apple.com")!)
        ]

        viewModel.searchText = "  "
        let result = viewModel.filteredEntries(bookmarks: entries)
        #expect(result.count == entries.count)
    }

    @Test
    func filteredEntriesMatchesTitleURLAndHost() {
        let viewModel = BookmarksViewModel()
        let entries = [
            BookmarkEntry(title: "OpenAI", url: URL(string: "https://openai.com/research")!),
            BookmarkEntry(title: "Apple", url: URL(string: "https://developer.apple.com")!),
            BookmarkEntry(title: "Swift", url: URL(string: "https://swift.org")!)
        ]

        viewModel.searchText = "openai"
        #expect(viewModel.filteredEntries(bookmarks: entries).count == 1)

        viewModel.searchText = "developer.apple.com"
        #expect(viewModel.filteredEntries(bookmarks: entries).count == 1)

        viewModel.searchText = "swift.org"
        #expect(viewModel.filteredEntries(bookmarks: entries).count == 1)
    }
}

struct HistoryViewModelTests {
    @Test
    func filteredEntriesUsesTitleAndURL() {
        let viewModel = HistoryViewModel()
        let entries = [
            HistoryEntry(title: "Docs", url: URL(string: "https://developer.apple.com/documentation")!),
            HistoryEntry(title: "Search", url: URL(string: "https://duckduckgo.com/?q=swift")!)
        ]

        viewModel.searchText = "docs"
        #expect(viewModel.filteredEntries(entries: entries).count == 1)

        viewModel.searchText = "duckduckgo.com"
        #expect(viewModel.filteredEntries(entries: entries).count == 1)
    }

    @Test
    func sectionsGroupsTodayAndYesterday() {
        let viewModel = HistoryViewModel()
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: now)!
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let entries = [
            HistoryEntry(title: "Today Item", url: URL(string: "https://example.com/today")!, date: today),
            HistoryEntry(title: "Yesterday Item", url: URL(string: "https://example.com/yesterday")!, date: yesterday)
        ]

        let sections = viewModel.sections(filteredEntries: entries)
        #expect(sections.count == 2)
        #expect(sections.first?.title == "Today")
        #expect(sections.last?.title == "Yesterday")
    }
}

struct BrowserManagerTests {
    @Test
    @MainActor
    func urlFromUserInputPrefersDirectURL() {
        let manager = BrowserManager()
        let settings = AppSettings()
        manager.appSettings = settings

        let url = manager.urlFromUserInput("https://example.com/path")
        #expect(url.absoluteString == "https://example.com/path")
    }

    @Test
    @MainActor
    func urlFromUserInputAddsHTTPSForHostnames() {
        let manager = BrowserManager()
        let settings = AppSettings()
        manager.appSettings = settings

        let url = manager.urlFromUserInput("example.com")
        #expect(url.absoluteString == "https://example.com")
    }

    @Test
    @MainActor
    func urlFromUserInputFallsBackToSearchEngine() {
        let manager = BrowserManager()
        let settings = AppSettings()
        settings.defaultSearchEngine = .bing
        manager.appSettings = settings

        let url = manager.urlFromUserInput("swift ui")
        #expect(url.absoluteString == "https://www.bing.com/search?q=swift%20ui")
    }

    @Test
    @MainActor
    func urlFromUserInputUsesSearchHomepageWhenEmpty() {
        let manager = BrowserManager()
        let settings = AppSettings()
        settings.defaultSearchEngine = .duckduckgo
        manager.appSettings = settings

        let url = manager.urlFromUserInput("   ")
        #expect(url.absoluteString == "https://duckduckgo.com")
    }
}
