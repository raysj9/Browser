//
//  PageMenuVerticalButton.swift
//  Browser
//

import SwiftUI

struct PageMenuVerticalButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.title2)
                Text(title)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 4)
        }
        .buttonStyle(.plain)
    }
}
