//
//  TabPreviewCard.swift
//  Browser
//

import SwiftUI

struct TabPreviewCard: View {
    let tab: BrowserTab
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.gray)
                    .frame(height: 260)

                Button {
                    onDelete()
                } label: {
                    Image(systemName: "xmark")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(.systemGray3))
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
    }
}
