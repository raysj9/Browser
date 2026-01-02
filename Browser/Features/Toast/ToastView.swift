import SwiftUI

struct ToastView: View {
    let toast: ToastItem

    var body: some View {
        HStack(spacing: 10) {
            if let systemImage = toast.systemImage {
                Image(systemName: systemImage)
                    .font(.headline)
            }

            Text(toast.message)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .foregroundStyle(.primary)
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .glassEffect(.regular.interactive(), in: .capsule)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2)

        ToastView(toast: ToastItem(message: "Bookmark added", systemImage: "star.fill"))
    }
}
