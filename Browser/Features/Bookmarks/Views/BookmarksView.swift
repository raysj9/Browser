import SwiftUI
import SwiftData
import UIKit

struct BookmarksView: View {
    @Query(sort: \BookmarkEntry.date, order: .reverse)
    private var bookmarks: [BookmarkEntry]

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(BrowserManager.self) private var browserManager

    @State private var model = BookmarksViewModel()

    var filteredBookmarks: [BookmarkEntry] { model.filteredEntries(bookmarks: bookmarks) }

    var body: some View {
        List {
            if filteredBookmarks.isEmpty {
                Section {
                    ContentUnavailableView(
                        model.searchText.isEmpty ? "Bookmarks are Empty" : "No Results",
                        systemImage: model.searchText.isEmpty ? "tray" : "magnifyingglass"
                    )
                }
            } else {
                ForEach(filteredBookmarks) { bookmark in
                    row(for: bookmark)
                }
                .onDelete { indexSet in
                    model.delete(bookmarks: indexSet.map { filteredBookmarks[$0] })
                }
            }
        }
        .navigationTitle("Bookmarks")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $model.searchText, prompt: "Search Bookmarks")
        .task {
            model.modelContext = modelContext
        }
        .toolbar {
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
                    "Clear all bookmarks?",
                    isPresented: $model.isConfirmingClearAll,
                    titleVisibility: .visible
                ) {
                    Button("Clear All", role: .destructive) {
                        model.clearAll(bookmarks: bookmarks)
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This will remove all saved bookmarks from this device.")
                }
                .disabled(filteredBookmarks.isEmpty)
            }
        }
    }

    @ViewBuilder
    private func row(for bookmark: BookmarkEntry) -> some View {
        Button {
            browserManager.load(url: bookmark.url)
            dismiss()
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(bookmark.title)
                    .font(.headline)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Text(bookmark.url.host ?? bookmark.url.absoluteString)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Text("•")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(bookmark.date, style: .date)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                browserManager.load(url: bookmark.url)
                dismiss()
            } label: {
                Label("Open", systemImage: "safari")
            }

            Button {
                UIPasteboard.general.string = bookmark.url.absoluteString
            } label: {
                Label("Copy Link", systemImage: "doc.on.doc")
            }

            Button(role: .destructive) {
                model.delete(bookmarks: [bookmark])
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: BookmarkEntry.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let context = container.mainContext

    context.insert(
        BookmarkEntry(
            title: "Apple",
            url: URL(string: "https://apple.com")!,
            date: .now
        )
    )

    context.insert(
        BookmarkEntry(
            title: "Swift Forums",
            url: URL(string: "https://forums.swift.org")!,
            date: .now.addingTimeInterval(-7200)
        )
    )

    return
        NavigationStack { BookmarksView() }
            .modelContainer(container)
            .environment(BrowserManager())
}
