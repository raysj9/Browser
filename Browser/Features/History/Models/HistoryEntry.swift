//
//  HistoryEntry.swift
//  Browser
//

import Foundation
import SwiftData

@Model
final class HistoryEntry: Hashable, Identifiable {
    var id: UUID
    var title: String
    var url: URL
    var date: Date
    
    init(id: UUID = UUID(), title: String, url: URL, date: Date = .now) {
        self.id = id
        self.title = title
        self.url = url
        self.date = date
    }
}
