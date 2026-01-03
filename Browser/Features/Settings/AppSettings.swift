import Foundation
import SwiftUI

@Observable
class AppSettings {
    var darkMode = false
    
    @ObservationIgnored
    @AppStorage("restoreSessionOnLaunch") var restoreSessionOnLaunch: Bool = true
    
    @ObservationIgnored
    @AppStorage("aiFeaturesEnabled") var aiFeaturesEnabled: Bool = true
    
    @ObservationIgnored
    @AppStorage("homepageURL") var homepageURLString: String = ""
    
    @ObservationIgnored
    @AppStorage("defaultSearchEngine") private var searchEngineRawValue: String = SearchEngine.google.rawValue
    
    var defaultSearchEngine: SearchEngine {
        get {
            SearchEngine(rawValue: searchEngineRawValue) ?? .google
        }
        set {
            searchEngineRawValue = newValue.rawValue
        }
    }
    
    var homepageURL: URL? {
        let trimmed = homepageURLString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        if let directURL = URL(string: trimmed), directURL.scheme != nil {
            return directURL
        }
        
        return URL(string: "https://\(trimmed)")
    }
}
