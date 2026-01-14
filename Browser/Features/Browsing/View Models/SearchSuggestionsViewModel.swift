import Foundation
import SwiftUI

@MainActor
@Observable
final class SearchSuggestionsViewModel {
    var suggestions: [String] = []

    private var suggestionTask: Task<Void, Never>?

    func updateSuggestions(query: String, engine: SearchEngine) {
        suggestionTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            suggestions = []
            return
        }

        suggestionTask = Task {
            try? await Task.sleep(for: .milliseconds(250))
            guard !Task.isCancelled else { return }

            let url = engine.suggestionsURL(for: trimmed)
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let parsed = engine.parseSuggestions(from: data)
                let limited = Array(parsed.prefix(10))
                if !Task.isCancelled {
                    suggestions = limited
                }
            } catch {
                if !Task.isCancelled {
                    suggestions = []
                }
            }
        }
    }

    func clear() {
        suggestionTask?.cancel()
        suggestions = []
    }
}
