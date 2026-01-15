import SwiftUI

struct ToolbarView: View {
    @Environment(BrowserManager.self) private var manager
    let tabsTransitionNamespace: Namespace.ID

    var body: some View {
        HStack {
            ForEach(BrowserToolbarItem.allCases, id: \.self) { item in
                if item == .tabs {
                    Button {
                        manager.handle(item.action)
                    } label: {
                        Image(systemName: item.systemImage)
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                    }
                    .matchedTransitionSource(id: "tabs-button", in: tabsTransitionNamespace)
                    .buttonStyle(.plain)
                    .disabled(manager.isToolbarButtonDisabled(item))
                    .padding(item == .menu ? 4 : 0)
                    .contentShape(Rectangle())
                } else {
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
        }
        .background(TouchBlockingView())
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
    }
}
