import SwiftUI
import WebKit

struct PageMenuSheet: View {
    @Environment(BrowserManager.self) private var browser
    @Environment(ToastManager.self) private var toastManager
    @Environment(\.dismiss) private var dismiss
    @State private var bookmarkHapticTrigger = false
    
    var body: some View {
        VStack {
            List {
                Section {
                    Button {
                        let didAdd = browser.addBookmarkForCurrentPage()
                        dismiss()
                        browser.isPresentingPageMenuSheet = false
                        if didAdd {
                            bookmarkHapticTrigger.toggle()
                            Task { @MainActor in
                                try? await Task.sleep(for: .milliseconds(250))
                                toastManager.show(
                                    message: "Bookmark added",
                                    systemImage: "star.fill",
                                    trailingSystemImage: "chevron.right",
                                    action: {
                                        browser.isPresentingBookmarksSheet = true
                                    }
                                )
                            }
                        }
                    } label: {
                        Label("Bookmark Page", systemImage: "star")
                            .labelStyle(.menu)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    Label("Find in Page...", systemImage: "magnifyingglass")
                        .labelStyle(.menu)

                    if let url = browser.webView.url {
                        ShareLink(item: url) {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .labelStyle(.menu)
                                .contentShape(Rectangle())
                        }
                        .onTapGesture {
                            browser.isPresentingPageMenuSheet = false
                        }
                        .buttonStyle(.plain)
                    } else {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .labelStyle(.menu)
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    HStack {
                        Spacer()
                        
                        PageMenuVerticalButton(
                            title: "Bookmarks",
                            systemImage: "star"
                        ) {
                            browser.isPresentingPageMenuSheet = false
                            browser.isPresentingBookmarksSheet = true
                        }
                        
                        Spacer()
                        
                        PageMenuVerticalButton(
                            title: "History",
                            systemImage: "clock"
                        ) {
                            browser.isPresentingPageMenuSheet = false
                            browser.isPresentingHistorySheet = true
                        }
                        
                        Spacer()
                    }
                }
                
                Section {
                    Button {
                        browser.isPresentingPageMenuSheet = false
                        browser.isPresentingSettingsSheet = true
                    } label: {
                        Label("Settings", systemImage: "gear")
                            .labelStyle(.menu)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .scrollContentBackground(.hidden)
            .scrollDisabled(true)
        }
        .sensoryFeedback(.success, trigger: bookmarkHapticTrigger)
    }
}


#Preview {
    PageMenuSheet()
        .environment(BrowserManager())
        .environment(ToastManager())
}
