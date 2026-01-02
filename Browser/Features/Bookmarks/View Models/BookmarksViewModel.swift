import SwiftData
import SwiftUI

@Observable
class BookmarksViewModel {
    var modelContext: ModelContext?

    var searchText = ""
    var selection: Set<UUID> = []
    var isConfirmingClearAll = false

    func filteredEntries(bookmarks: [BookmarkEntry]) -> [BookmarkEntry] {
        let needle = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty else { return bookmarks }

        return bookmarks.filter { bookmark in
            bookmark.title.localizedCaseInsensitiveContains(needle)
            || bookmark.url.absoluteString.localizedCaseInsensitiveContains(needle)
            || (bookmark.url.host?.localizedCaseInsensitiveContains(needle) ?? false)
        }
    }

    // MARK: - Swift Data

    func delete(bookmarks: [BookmarkEntry]) {
        for bookmark in bookmarks {
            modelContext?.delete(bookmark)
        }
        selection.subtract(bookmarks.map(\.id))
    }

    func clearAll(bookmarks: [BookmarkEntry]) {
        delete(bookmarks: bookmarks)
        selection.removeAll()
    }
}
