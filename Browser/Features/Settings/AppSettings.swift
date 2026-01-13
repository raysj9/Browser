import Foundation
import SwiftUI

enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

@Observable
class AppSettings {
    var appAppearance: AppAppearance = .system {
        didSet {
            appearanceRawValue = appAppearance.rawValue
        }
    }
    
    @ObservationIgnored
    @AppStorage("restoreSessionOnLaunch") var restoreSessionOnLaunch: Bool = true
    
    @ObservationIgnored
    @AppStorage("aiFeaturesEnabled") var aiFeaturesEnabled: Bool = true
    
    @ObservationIgnored
    @AppStorage("homepageURL") var homepageURLString: String = ""
    
    @ObservationIgnored
    @AppStorage("defaultSearchEngine") private var searchEngineRawValue: String = SearchEngine.google.rawValue
    
    @ObservationIgnored
    @AppStorage("appAppearance") private var appearanceRawValue: String = AppAppearance.system.rawValue

    var defaultSearchEngine: SearchEngine = .google {
        didSet {
            searchEngineRawValue = defaultSearchEngine.rawValue
        }
    }

    init() {
        appAppearance = AppAppearance(rawValue: appearanceRawValue) ?? .system
        defaultSearchEngine = SearchEngine(rawValue: searchEngineRawValue) ?? .google
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
