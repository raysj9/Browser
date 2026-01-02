import SwiftData
import SwiftUI

@Observable
class HistoryViewModel {
    var modelContext: ModelContext?
    
    var searchText = ""
    var selection: Set<UUID> = []
    var isConfirmingClearAll = false
    
    func filteredEntries(entries: [HistoryEntry]) -> [HistoryEntry] {
        let needle = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty else { return entries }
        
        return entries.filter { entry in
            entry.title.localizedCaseInsensitiveContains(needle)
            || entry.url.absoluteString.localizedCaseInsensitiveContains(needle)
            || (entry.url.host?.localizedCaseInsensitiveContains(needle) ?? false)
        }
    }
    
    func sections(filteredEntries: [HistoryEntry]) -> [HistorySection] {
        var result: [HistorySection] = []
        let calendar = Calendar.current
        
        func sectionTitle(for date: Date) -> String {
            if calendar.isDateInToday(date) { return "Today" }
            if calendar.isDateInYesterday(date) { return "Yesterday" }
            return date.formatted(.dateTime.month(.wide).day().year())
        }
        
        for entry in filteredEntries {
            let title = sectionTitle(for: entry.date)
            if result.last?.id == title {
                result[result.count - 1].entries.append(entry)
            } else {
                result.append(HistorySection(id: title, title: title, entries: [entry]))
            }
        }
        
        return result
    }
    
    // MARK: - Swift Data
    
    func delete(entries: [HistoryEntry]) {
        for entry in entries {
            modelContext?.delete(entry)
        }
        selection.subtract(entries.map(\.id))
    }
    
    func clearAll(entries: [HistoryEntry]) {
        delete(entries: entries)
        selection.removeAll()
    }
}
