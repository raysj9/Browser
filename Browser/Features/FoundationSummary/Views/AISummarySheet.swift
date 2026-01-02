import SwiftUI
import WebKit

struct AISummarySheet: View {
    @Environment(BrowserManager.self) private var browser
    @State private var model = PageSummaryViewModel()
    @State private var isLoadingPulse = false

    var body: some View {
        VStack(spacing: 16) {
            Text("AI Summary")
                .font(.headline)

            content
            
            if model.state == .loading {
                Spacer()
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .task(id: browser.webView.url) {
            await model.summarizeIfNeeded(webView: browser.webView)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                isLoadingPulse = true
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .idle, .loading:
            skeletonView

        case .streaming(let partial):
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if let title = partial.title, !title.isEmpty {
                        Text(title)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if let tldr = partial.tldr, !tldr.isEmpty {
                        Text(tldr)
                            .font(.subheadline)
                    } else {
                        Text("Generating summary…")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    streamingSection(title: "Key Points", items: partial.key_points)
                    streamingSection(title: "Important Details", items: partial.important_details)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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

    private func streamingSection(title: String, items: [String]?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            if let items, !items.isEmpty {
                ForEach(items, id: \.self) { item in
                    Text("• \(item)")
                        .font(.subheadline)
                }
            } else {
                Text("Generating…")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var skeletonView: some View {
        VStack(alignment: .leading, spacing: 12) {
            skeletonLine(width: 120, height: 14)
            skeletonLine(height: 16)
            skeletonLine(height: 16)
            skeletonLine(width: 200, height: 12)

            VStack(alignment: .leading, spacing: 8) {
                skeletonLine(width: 80, height: 10)
                skeletonLine(height: 12)
                skeletonLine(height: 12)
                skeletonLine(height: 12)
            }

            VStack(alignment: .leading, spacing: 8) {
                skeletonLine(width: 110, height: 10)
                skeletonLine(height: 12)
                skeletonLine(height: 12)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func skeletonLine(width: CGFloat? = nil, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: height / 2, style: .continuous)
            .fill(.gray.opacity(0.25))
            .frame(width: width, height: height)
            .opacity(isLoadingPulse ? 0.35 : 0.75)
    }
}

#Preview {
    AISummarySheet()
        .environment(BrowserManager())
}
