import Foundation

struct ToastItem: Identifiable {
    let id: UUID
    let message: String
    let systemImage: String?
    let trailingSystemImage: String?
    let action: (() -> Void)?

    init(
        id: UUID = UUID(),
        message: String,
        systemImage: String? = nil,
        trailingSystemImage: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.id = id
        self.message = message
        self.systemImage = systemImage
        self.trailingSystemImage = trailingSystemImage
        self.action = action
    }
}
