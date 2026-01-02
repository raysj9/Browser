import SwiftUI
import WebKit

struct AISummarySheet: View {
    @Environment(BrowserManager.self) private var browser
    @State private var model = PageSummaryViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Text("AI Summary")
                .font(.headline)

            content
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .task(id: browser.webView.url) {
            await model.summarizeIfNeeded(webView: browser.webView)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .idle, .loading:
            VStack(spacing: 12) {
                ProgressView()
                Text("Summarizing this page…")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

        case .unavailable(let message):
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

        case .failed(let message):
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

        case .ready(let summary):
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if !summary.title.isEmpty {
                        Text(summary.title)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Text(summary.tldr)
                        .font(.subheadline)

                    section(title: "Key Points", items: summary.keyPoints)
                    section(title: "Important Details", items: summary.importantDetails)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func section(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            ForEach(items, id: \.self) { item in
                Text("• \(item)")
                    .font(.subheadline)
            }
        }
    }
}

#Preview {
    AISummarySheet()
        .environment(BrowserManager())
}
