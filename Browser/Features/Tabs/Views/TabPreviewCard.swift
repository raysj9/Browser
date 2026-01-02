import SwiftUI
import UIKit

struct TabPreviewCard: View {
    let tab: BrowserTab
    let isSelected: Bool
    let onDelete: () -> Void
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.gray.opacity(0.4))
                    .frame(height: 260)
                    .overlay {
                        if let image = previewImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 260)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.2), lineWidth: 1)
                    }

                Button {
                    onDelete()
                } label: {
                    Image(systemName: "xmark")
                        .font(.subheadline)
                        .fontWeight(.semibold)
//                        .foregroundStyle(Color(.systemGray3))
                        .padding(6)
                        .glassEffect(.clear.tint(.black.opacity(0.70)), in: .circle)
                }
                .buttonStyle(.plain)
                .padding(8)
            }

            HStack(alignment: .center, spacing: 4) {
                Image(systemName: "globe")
                    .foregroundStyle(.white.opacity(0.8))

                Text(tab.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }
            .padding(.leading, 4)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }

    private var previewImage: UIImage? {
        guard let data = tab.previewImageData else { return nil }
        return UIImage(data: data)
    }
}
