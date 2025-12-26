//
//  PageMenuSheet.swift
//  Browser
//

import SwiftUI
import WebKit

struct PageMenuSheet: View {
    @Environment(BrowserManager.self) private var browser
    
    var body: some View {
        VStack {
            List {
                Section {
                    Label("Bookmark Page", systemImage: "star")
                        .labelStyle(.menu)
                    
                    Label("Find in Page...", systemImage: "magnifyingglass")
                        .labelStyle(.menu)

                    Label("Share", systemImage: "square.and.arrow.up")
                        .labelStyle(.menu)
                }

                Section {
                    HStack {
                        Spacer()
                        
                        PageMenuVerticalButton(
                            title: "Bookmarks",
                            systemImage: "star"
                        ) {
                            print("Pressed Bookmarks")
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
    }
}


#Preview {
    PageMenuSheet()
        .environment(BrowserManager())
}
