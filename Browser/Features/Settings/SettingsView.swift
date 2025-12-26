//
//  SettingsView.swift
//  Browser
//

// WIP

import SwiftUI

struct SettingsView: View {
    @Environment(AppSettings.self) private var appSettings

    var body: some View {
        NavigationStack {
            List {
                Section("General") {
                    NavigationLink {
                        DefaultSearchEngineView()
                    } label: {
                        HStack {
                            Text("Search")
                            
                            Spacer()
                            
                            Text(appSettings.defaultSearchEngine.title)
                        }
                    }
                }
            }
        }
    }
}

struct DefaultSearchEngineView: View {
    @Environment(AppSettings.self) private var appSettings
    
    var body: some View {
        @Bindable var settings: AppSettings = appSettings

        List {
            Picker("Select a Default Search Engine", selection: $settings.defaultSearchEngine) {
                ForEach(SearchEngine.allCases, id: \.self) { engine in
                    HStack(spacing: 12) {
                        engine.logo
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        
                        Text(engine.title)
                    }
                    .tag(engine)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
        .navigationTitle("Default Search Engine")
    }
}

#Preview {
    DefaultSearchEngineView()
        .environment(AppSettings())
}

#Preview {
    SettingsView()
        .environment(AppSettings())
}
