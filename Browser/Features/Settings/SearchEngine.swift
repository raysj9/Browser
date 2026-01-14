import Foundation
import SwiftUI

enum SearchEngine: String, CaseIterable, Codable {
    case google
    case bing
    case duckduckgo
    
    var title: String {
        switch self {
        case .google: "Google"
        case .bing: "Bing"
        case .duckduckgo: "DuckDuckGo"
        }
    }
    
    var logo: Image {
        switch self {
        case .google: Image("google-logo")
        case .bing: Image("bing-logo")
        case .duckduckgo: Image("duckduckgo-logo")
        }
    }
    
    func searchURL(for query: String) -> URL {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If no query, return the search engine's homepage
        guard !trimmedQuery.isEmpty else {
            switch self {
            case .google:
                return URL(string: "https://www.google.com")!
            case .bing:
                return URL(string: "https://www.bing.com")!
            case .duckduckgo:
                return URL(string: "https://duckduckgo.com")!
            }
        }
        
        let encodedQuery = trimmedQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? trimmedQuery
        let urlString: String
        
        switch self {
        case .google:
            urlString = "https://www.google.com/search?q=\(encodedQuery)"
        case .bing:
            urlString = "https://www.bing.com/search?q=\(encodedQuery)"
        case .duckduckgo:
            urlString = "https://duckduckgo.com/?q=\(encodedQuery)"
        }
        
        return URL(string: urlString)!
    }

    func suggestionsURL(for query: String) -> URL {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let encodedQuery = trimmedQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? trimmedQuery

        let urlString: String
        switch self {
        case .google:
            urlString = "https://suggestqueries.google.com/complete/search?client=firefox&q=\(encodedQuery)"
        case .bing:
            urlString = "https://api.bing.com/osjson.aspx?query=\(encodedQuery)"
        case .duckduckgo:
            urlString = "https://duckduckgo.com/ac/?q=\(encodedQuery)"
        }

        return URL(string: urlString)!
    }

    func parseSuggestions(from data: Data) -> [String] {
        switch self {
        case .duckduckgo:
            let json = try? JSONSerialization.jsonObject(with: data)
            guard let array = json as? [[String: Any]] else { return [] }
            return array.compactMap { $0["phrase"] as? String }
        case .google, .bing:
            let json = try? JSONSerialization.jsonObject(with: data)
            guard let array = json as? [Any], array.count > 1 else { return [] }
            return (array[1] as? [String]) ?? []
        }
    }
}
