//
//  BrowserApp.swift
//  Browser
//

import SwiftUI
import SwiftData

@main
struct BrowserApp: App {
    @State private var browserManager = BrowserManager()
    @State private var tabsManager = TabsManager()
    @State private var appSettings = AppSettings()
    
    var body: some Scene {
        WindowGroup {
            BrowserView()
                .environment(browserManager)
                .environment(tabsManager)
                .environment(appSettings)
        }
        .modelContainer(for: HistoryEntry.self)
    }
}
