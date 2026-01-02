import SwiftUI

@Observable
@MainActor
final class ToastManager {
    var toast: ToastItem?

    @ObservationIgnored
    private var dismissTask: Task<Void, Never>?

    func show(message: String, systemImage: String? = nil, duration: TimeInterval = 3.0, action: (() -> Void)? = nil) {
        dismissTask?.cancel()

        withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
            toast = ToastItem(message: message, systemImage: systemImage, action: action)
        }

        dismissTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            dismiss()
        }
    }

    func dismiss() {
        dismissTask?.cancel()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
            toast = nil
        }
    }
}
