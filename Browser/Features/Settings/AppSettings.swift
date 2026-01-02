import Foundation
import SwiftUI

@Observable
class AppSettings {
    var darkMode = false
    
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
}
