import SwiftUI
import FoundationModels

struct AddressBarView: View {
    @Environment(BrowserManager.self) private var browser
    @Environment(AppSettings.self) private var appSettings

    @FocusState private var isFieldFocused: Bool
    @State private var suggestionsModel = SearchSuggestionsViewModel()

    private var urlBinding: Binding<String> {
        Binding(
            get: { browser.urlString },
            set: { browser.urlString = $0 }
        )
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                if !browser.addressBarIsActive {
                    if supportsFoundationModels && !isSearchEnginePage {
                        summaryButton
                    } else {
                        summaryButton
                            .hidden()
                            .accessibilityHidden(true)
                    }
                }

                Spacer()

                if browser.addressBarIsActive {
                    addressTextField
                } else {
                    addressText
                }

                Spacer()

                if browser.addressBarIsActive {
                    clearAddressBarTextButton
                    cancelButton
                } else {
                    refreshButton
                }
            }
            .contentShape(Rectangle())
            .background(TouchBlockingView())
            .padding(.horizontal)
            .padding(.vertical)
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemBackground))
            .overlay(alignment: .bottom) {
                ProgressView(value: browser.estimatedProgress)
                    .progressViewStyle(.linear)
                    .frame(maxWidth: .infinity)
                    .opacity(browser.isLoading ? 1 : 0)
                    .padding(.bottom, 4)
            }
            .onChange(of: browser.addressBarIsActive) { _, active in
                if active {
                    isFieldFocused = true
                } else {
                    isFieldFocused = false
                    suggestionsModel.clear()
                }
            }

            if browser.addressBarIsActive && !suggestionsModel.suggestions.isEmpty {
                suggestionsList
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onChange(of: browser.urlString) { _, newValue in
            guard browser.addressBarIsActive else { return }
            suggestionsModel.updateSuggestions(
                query: newValue,
                engine: appSettings.defaultSearchEngine
            )
        }
    }
    
    var addressTextField: some View {
        TextField("", text: urlBinding)
            .fontWeight(.semibold)
            .keyboardType(.webSearch)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused($isFieldFocused)
            .onAppear {
                isFieldFocused = true
            }
            .onSubmit {
                browser.addressBarIsActive = false
                isFieldFocused = false
                suggestionsModel.clear()

                let url = browser.urlFromUserInput(browser.urlString)
                browser.load(url: url)
            }
    }
    
    var addressText: some View {
        let displayText = addressBarDisplayText()
        return Text(displayText.isEmpty ? "Search or enter website name" : displayText)
            .fontWeight(.semibold)
            .lineLimit(1)
            .contentShape(Rectangle())
            .onTapGesture {
                browser.showAddressBar()
                browser.addressBarIsActive = true
                isFieldFocused = true
            }
    }
    
    var clearAddressBarTextButton: some View {
        Button {
            browser.urlString = ""
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.title3)
        }
        .buttonStyle(.plain)
    }
    
    var refreshButton: some View {
        Button {
            browser.refreshPage()
        } label: {
            Image(systemName: "arrow.clockwise")
        }
        .buttonStyle(.plain)
    }

    var summaryButton: some View {
        Button {
            browser.isPresentingSummarySheet = true
        } label: {
            Image(systemName: "sparkles")
        }
        .buttonStyle(.plain)
    }

    private var supportsFoundationModels: Bool {
        appSettings.aiFeaturesEnabled && SystemLanguageModel.default.availability == .available
    }
    
    var cancelButton: some View {
        Button {
            browser.addressBarIsActive.toggle()
        } label: {
            Text("Cancel")
                .foregroundStyle(.blue)
        }
        .buttonStyle(.plain)
    }

    var suggestionsList: some View {
        VStack(spacing: 0) {
            ForEach(suggestionsModel.suggestions, id: \.self) { suggestion in
                Button {
                    applySuggestion(suggestion)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        Text(suggestion)
                            .lineLimit(1)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if suggestion != suggestionsModel.suggestions.last {
                    Divider()
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func applySuggestion(_ suggestion: String) {
        browser.urlString = suggestion
        browser.addressBarIsActive = false
        isFieldFocused = false
        suggestionsModel.clear()

        let url = browser.urlFromUserInput(suggestion)
        browser.load(url: url)
    }

    private func addressBarDisplayText() -> String {
        let trimmed = browser.urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }
        guard let url = URL(string: trimmed),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let host = components.host else {
            return trimmed
        }
        if let query = searchQueryText(host: host, components: components) {
            return query
        }
        if host.hasPrefix("www.") {
            return String(host.dropFirst(4))
        }
        return host
    }

    private var isSearchResultsPage: Bool {
        let trimmed = browser.urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let url = URL(string: trimmed),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let host = components.host else {
            return false
        }
        return searchQueryText(host: host, components: components) != nil
    }

    private var isSearchEnginePage: Bool {
        let trimmed = browser.urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let url = URL(string: trimmed),
              let host = URLComponents(url: url, resolvingAgainstBaseURL: false)?.host else {
            return false
        }
        return isSearchEngineHost(host) || isSearchResultsPage
    }

    private func searchQueryText(host: String, components: URLComponents) -> String? {
        guard isSearchEngineHost(host),
              let query = components.queryItems?.first(where: { $0.name == "q" })?.value,
              !query.isEmpty else {
            return nil
        }
        return query.removingPercentEncoding ?? query
    }

    private func isSearchEngineHost(_ host: String) -> Bool {
        switch host {
        case "www.google.com", "google.com",
             "www.bing.com", "bing.com",
             "www.duckduckgo.com", "duckduckgo.com":
            return true
        default:
            return false
        }
    }
}

#Preview {
    BrowserView()
        .environment(BrowserManager())
}
