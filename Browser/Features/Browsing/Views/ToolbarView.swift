//
//  ToolbarView.swift
//  Browser
//

import SwiftUI

struct ToolbarView: View {
    @Environment(BrowserManager.self) private var manager

    var body: some View {
        HStack {
            ForEach(BrowserToolbarItem.allCases, id: \.self) { item in
                Button {
                    manager.handle(item.action)
                } label: {
                    Image(systemName: item.systemImage)
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .disabled(manager.isToolbarButtonDisabled(item))
                .padding(item == .menu ? 4 : 0)
                .contentShape(Rectangle())
            }
        }
        .background(TouchBlockingView())
        .padding(.horizontal)
        .padding(.vertical)
        .glassEffect(.regular.interactive())
    }
}
