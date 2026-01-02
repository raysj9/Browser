import SwiftUI
import SwiftData
import UIKit

struct HistorySection: Identifiable {
    let id: String
    let title: String
    var entries: [HistoryEntry]
}

struct HistoryView: View {
    @Query(sort: \HistoryEntry.date, order: .reverse)
    private var entries: [HistoryEntry]
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode
    @Environment(BrowserManager.self) private var browserManager
    
    @State private var model = HistoryViewModel()
    
    var filteredEntries: [HistoryEntry] { model.filteredEntries(entries: entries) }
    var sections: [HistorySection] { model.sections(filteredEntries: filteredEntries) }
    
    var body: some View {
        List(selection: $model.selection) {
            if filteredEntries.isEmpty {
                Section {
                    ContentUnavailableView(
                        model.searchText.isEmpty ? "Search History is Empty" : "No Results",
                        systemImage: model.searchText.isEmpty ? "tray" : "magnifyingglass"
                    )
                }
            } else {
                ForEach(sections) { section in
                    Section(section.title) {
                        ForEach(section.entries) { entry in
                            row(for: entry)
                        }
                        .onDelete { indexSet in
                            model.delete(entries: indexSet.map { section.entries[$0] })
                        }
                    }
                }
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $model.searchText, prompt: "Search History")
        .task {
            model.modelContext = modelContext
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        model.isConfirmingClearAll = true
                    } label: {
                        Label("Clear All", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .confirmationDialog(
                    "Clear all history?",
                    isPresented: $model.isConfirmingClearAll,
                    titleVisibility: .visible
                ) {
                    Button("Clear All", role: .destructive) {
                        model.clearAll(entries: entries)
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This will remove all saved browsing history from this device.")
                }
                .disabled(filteredEntries.isEmpty)
            }
        }
    }
    
    @ViewBuilder
    private func row(for entry: HistoryEntry) -> some View {
        let isEditing = editMode?.wrappedValue.isEditing ?? false
        
        Button {
            guard !isEditing else { return }
            browserManager.load(url: entry.url)
            dismiss()
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.headline)
                    .lineLimit(2)
                
                HStack(spacing: 6) {
                    Text(entry.url.host ?? entry.url.absoluteString)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
                    Text("•")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(entry.date, style: .time)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                browserManager.load(url: entry.url)
                dismiss()
            } label: {
                Label("Open", systemImage: "safari")
            }
            
            Button {
                UIPasteboard.general.string = entry.url.absoluteString
            } label: {
                Label("Copy Link", systemImage: "doc.on.doc")
            }
            
            Button(role: .destructive) {
                model.delete(entries: [entry])
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: HistoryEntry.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let context = container.mainContext

    context.insert(
        HistoryEntry(
            title: "Apple",
            url: URL(string: "https://apple.com")!,
            date: .now
        )
    )

    context.insert(
        HistoryEntry(
            title: "Swift Forums",
            url: URL(string: "https://forums.swift.org")!,
            date: .now.addingTimeInterval(-3600)
        )
    )

    return
        NavigationStack { HistoryView() }
            .modelContainer(container)
            .environment(BrowserManager())
}
