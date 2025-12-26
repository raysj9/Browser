//
//  BrowserTab.swift
//  Browser
//

import SwiftUI

struct BrowserTab: Identifiable {
    let id: UUID = UUID()
    let title: String
    let url: URL
    let lastAccessed: Date
}

extension BrowserTab {
    static let sample: [BrowserTab] = [
        BrowserTab(
            title: "The Verge",
            url: URL(string: "https://www.theverge.com")!,
            lastAccessed: Date().addingTimeInterval(-1800)
        ),
        BrowserTab(
            title: "SwiftUI Documentation",
            url: URL(string: "https://developer.apple.com/documentation/swiftui")!,
            lastAccessed: Date().addingTimeInterval(-120)
        ),
        BrowserTab(
            title: "VCU",
            url: URL(string: "https://www.vcu.edu")!,
            lastAccessed: Date().addingTimeInterval(-5400)
        ),
        BrowserTab(
            title: "GitHub",
            url: URL(string: "https://github.com")!,
            lastAccessed: Date().addingTimeInterval(-300)
        ),
        BrowserTab(
            title: "Hacker News",
            url: URL(string: "https://news.ycombinator.com")!,
            lastAccessed: Date().addingTimeInterval(-600)
        ),
        BrowserTab(
            title: "Reddit",
            url: URL(string: "https://www.reddit.com")!,
            lastAccessed: Date().addingTimeInterval(-900)
        ),
        BrowserTab(
            title: "YouTube",
            url: URL(string: "https://www.youtube.com")!,
            lastAccessed: Date().addingTimeInterval(-1200)
        ),
        BrowserTab(
            title: "Stack Overflow",
            url: URL(string: "https://stackoverflow.com")!,
            lastAccessed: Date().addingTimeInterval(-420)
        ),
        BrowserTab(
            title: "X",
            url: URL(string: "https://x.com")!,
            lastAccessed: Date().addingTimeInterval(-1500)
        ),
        BrowserTab(
            title: "9to5Mac",
            url: URL(string: "https://9to5mac.com")!,
            lastAccessed: Date().addingTimeInterval(-2100)
        ),
        BrowserTab(
            title: "Wikipedia",
            url: URL(string: "https://en.wikipedia.org")!,
            lastAccessed: Date().addingTimeInterval(-2400)
        ),
        BrowserTab(
            title: "Amazon",
            url: URL(string: "https://www.amazon.com")!,
            lastAccessed: Date().addingTimeInterval(-2700)
        ),
        BrowserTab(
            title: "Google Maps",
            url: URL(string: "https://maps.google.com")!,
            lastAccessed: Date().addingTimeInterval(-3000)
        ),
        BrowserTab(
            title: "Netflix",
            url: URL(string: "https://www.netflix.com")!,
            lastAccessed: Date().addingTimeInterval(-3300)
        ),
        BrowserTab(
            title: "Spotify Web Player",
            url: URL(string: "https://open.spotify.com")!,
            lastAccessed: Date().addingTimeInterval(-3600)
        ),
        BrowserTab(
            title: "MDN Web Docs",
            url: URL(string: "https://developer.mozilla.org")!,
            lastAccessed: Date().addingTimeInterval(-3900)
        ),
        BrowserTab(
            title: "Cloudflare",
            url: URL(string: "https://www.cloudflare.com")!,
            lastAccessed: Date().addingTimeInterval(-4200)
        ),
        BrowserTab(
            title: "Supabase",
            url: URL(string: "https://supabase.com")!,
            lastAccessed: Date().addingTimeInterval(-4500)
        ),
        BrowserTab(
            title: "Apple",
            url: URL(string: "https://www.apple.com")!,
            lastAccessed: Date().addingTimeInterval(-60)
        ),
        BrowserTab(
            title: "OpenAI",
            url: URL(string: "https://www.openai.com")!,
            lastAccessed: Date().addingTimeInterval(-4800)
        )
    ]
}
