import Foundation
import SwiftData

@Model
final class BrowserTab: Hashable, Identifiable {
    var id: UUID
    var title: String
    var url: URL
    var lastAccessed: Date
    var isPrivate: Bool
    @Attribute(.externalStorage) var previewImageData: Data?

    init(
        id: UUID = UUID(),
        title: String,
        url: URL,
        lastAccessed: Date = .now,
        isPrivate: Bool = false,
        previewImageData: Data? = nil
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.lastAccessed = lastAccessed
        self.isPrivate = isPrivate
        self.previewImageData = previewImageData
    }
}
