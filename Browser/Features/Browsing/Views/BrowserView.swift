//
//  BrowserView.swift
//  Browser
//

import SwiftUI

struct BrowserView: View {
    @Environment(BrowserManager.self) private var manager
    @Environment(AppSettings.self) private var appSettings
    @Environment(\.modelContext) private var context

    var body: some View {
        @Bindable var managerBinding = manager
        @Bindable var settingsBinding = appSettings
        
        ZStack {
            WebView(webView: manager.webView)
                .ignoresSafeArea()
                .task {
                    manager.loadHomeIfNeeded(url: URL(string: "https://vcu.edu")!)
                }

            VStack {
                AddressBarView()
                    .padding(.horizontal, 30)

                Spacer()
                
                ToolbarView()
                    .padding(.horizontal, 30)
            }
            .padding(.bottom)
            .ignoresSafeArea(edges: .bottom)
        }
        .sheet(isPresented: $managerBinding.isPresentingHistorySheet, content: {
            NavigationStack {
                HistoryView()
            }
        })
        .sheet(isPresented: $managerBinding.isPresentingPageMenuSheet, content: {
            PageMenuSheet()
                .presentationDetents([.fraction(0.5)])
        })
        .sheet(isPresented: $managerBinding.isPresentingSettingsSheet, content: {
            SettingsView()
        })
        .task {
            manager.context = context
            manager.appSettings = appSettings
        }
    }
}

#Preview {
    NavigationStack {
        BrowserView()
            .environment(BrowserManager())
            .environment(AppSettings())
    }

}

