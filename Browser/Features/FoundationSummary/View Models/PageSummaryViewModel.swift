import Foundation
import FoundationModels
import SwiftUI
import WebKit

@Observable
@MainActor
final class PageSummaryViewModel {
    enum State: Equatable {
        case idle
        case loading
        case unavailable(String)
        case failed(String)
        case ready(PageSummary)
    }

    var state: State = .idle
    private var lastURL: URL?

    func summarizeIfNeeded(webView: WKWebView) async {
        guard webView.url != lastURL else { return }
        lastURL = webView.url
        await summarize(webView: webView)
    }

    func summarize(webView: WKWebView) async {
        let model = SystemLanguageModel.default

        switch model.availability {
        case .available:
            break
        case .unavailable(.deviceNotEligible):
            state = .unavailable("Device not eligible for Apple Intelligence.")
            return
        case .unavailable(.appleIntelligenceNotEnabled):
            state = .unavailable("Enable Apple Intelligence in Settings.")
            return
        case .unavailable(.modelNotReady):
            state = .unavailable("Model is downloading or not ready.")
            return
        case .unavailable(let other):
            state = .unavailable("Model unavailable: \(other)")
            return
        }

        state = .loading

        let title = webView.title?.trimmingCharacters(in: .whitespacesAndNewlines)
        let url = webView.url

        let pageText = await extractPageText(from: webView)
        let trimmed = pageText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            state = .failed("No readable page text found.")
            return
        }

        let chunks = chunkText(trimmed)

        if chunks.isEmpty {
            state = .failed("No readable content after cleanup.")
            return
        }

        do {
            var allPoints: [String] = []

            for (index, chunk) in chunks.enumerated() {
                let mapSession = LanguageModelSession(instructions: mapInstructions)
                let prompt = mapPrompt(title: title, index: index + 1, total: chunks.count, chunk: chunk)
                let response = try await mapSession.respond(to: prompt, generating: ChunkSummaryOutput.self)
                allPoints.append(contentsOf: response.content.summary_points)
            }

            let reduceSession = LanguageModelSession(instructions: reduceInstructions)
            let reducePrompt = reducePrompt(title: title, url: url, points: allPoints)
            let response = try await reduceSession.respond(to: reducePrompt, generating: PageSummaryOutput.self)

            let summary = PageSummary(
                title: response.content.title,
                tldr: response.content.tldr,
                keyPoints: response.content.key_points,
                importantDetails: response.content.important_details
            )

            state = .ready(summary)
        } catch {
            state = .failed("Summary failed. Please try again.")
        }
    }

    private func extractPageText(from webView: WKWebView) async -> String {
        await withCheckedContinuation { continuation in
            webView.evaluateJavaScript("document.body.innerText") { result, _ in
                continuation.resume(returning: result as? String ?? "")
            }
        }
    }

    private func chunkText(_ text: String) -> [String] {
        let normalized = normalize(text)
        let paragraphs = normalized
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count >= 40 }

        guard !paragraphs.isEmpty else { return [] }

        let minChars = 6000
        let maxChars = 9000

        var chunks: [String] = []
        var current: [String] = []
        var currentCount = 0

        for paragraph in paragraphs {
            let paragraphCount = paragraph.count

            if chunks.count >= 11 {
                current.append(paragraph)
                continue
            }

            if currentCount + paragraphCount > maxChars, currentCount >= minChars {
                chunks.append(current.joined(separator: "\n\n"))
                current = [paragraph]
                currentCount = paragraphCount
            } else {
                current.append(paragraph)
                currentCount += paragraphCount
            }
        }

        if !current.isEmpty {
            chunks.append(current.joined(separator: "\n\n"))
        }

        return chunks
    }

    private func normalize(_ text: String) -> String {
        var normalized = text.replacingOccurrences(of: "\r\n", with: "\n")
        normalized = normalized.replacingOccurrences(of: "\t", with: " ")

        let regex = try? NSRegularExpression(pattern: "\\n{3,}")
        let range = NSRange(normalized.startIndex..., in: normalized)
        normalized = regex?.stringByReplacingMatches(in: normalized, range: range, withTemplate: "\n\n") ?? normalized

        return normalized
    }

    private var mapInstructions: String {
        """
        You summarize web content accurately and concisely.
        
        Rules:
        - Ignore navigation text, repeated headings, ads, and legal boilerplate
        - Preserve factual details (names, dates, numbers)
        - Do not speculate or infer beyond the text
        - Be neutral and factual
        """
    }

    private var reduceInstructions: String {
        """
        You are a web page summarizer.
        
        Rules:
        - Synthesize across multiple summaries
        - Remove redundancy
        - Preserve important facts and structure
        - Do not add new information
        - Output must match the required JSON schema exactly
        """
    }

    private func mapPrompt(title: String?, index: Int, total: Int, chunk: String) -> String {
        """
        Title (if available): \(title ?? "")
        Chunk \(index) of \(total)

        Text:
        \(chunk)

        Task:
        Summarize this chunk into 3–5 concise bullet points capturing only the key facts.
        """
    }

    private func reducePrompt(title: String?, url: URL?, points: [String]) -> String {
        let bulletList = points.map { "- \($0)" }.joined(separator: "\n")
        return """
        Title (if available): \(title ?? "")
        URL (if available): \(url?.absoluteString ?? "")

        Here are bullet summaries from all chunks:
        \(bulletList)

        Task:
        Produce a final structured summary of the entire page using this exact JSON shape:
        {
          "title": "",
          "tldr": "",
          "key_points": ["", "", "", "", ""],
          "important_details": ["", "", ""]
        }
        """
    }
}
