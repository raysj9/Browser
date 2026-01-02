import SwiftUI
import SwiftData

@main
struct BrowserApp: App {
    @State private var browserManager = BrowserManager()
    @State private var tabsManager = TabsManager()
    @State private var appSettings = AppSettings()
    @State private var toastManager = ToastManager()
    
    var body: some Scene {
        WindowGroup {
            BrowserView()
                .environment(browserManager)
                .environment(tabsManager)
                .environment(appSettings)
                .environment(toastManager)
        }
        .modelContainer(for: [HistoryEntry.self, BookmarkEntry.self])
    }
}
