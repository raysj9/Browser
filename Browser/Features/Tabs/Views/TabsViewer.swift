// WIP

import SwiftUI
import SwiftData

struct TabsViewer: View {
    @Environment(BrowserManager.self) private var browserManager
    @Environment(TabsManager.self) private var tabsManager
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \BrowserTab.lastAccessed, order: .reverse) private var tabs: [BrowserTab]
    @State private var deleteHapticTrigger = false

    var body: some View {
        ZStack {
            tabsView

            VStack {
                Spacer()

                bottomToolbar
                    .padding(.horizontal)
            }
        }
        .sensoryFeedback(.impact, trigger: deleteHapticTrigger)
    }

    private var filteredTabs: [BrowserTab] {
        let isPrivate = tabsManager.tabSection == .privateTabs
        return tabs.filter { $0.isPrivate == isPrivate }
    }

    private var tabsView: some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        return ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(filteredTabs) { tab in
                    TabPreviewCard(
                        tab: tab,
                        isSelected: browserManager.currentTabID == tab.id,
                        onDelete: {
                            withAnimation(.snappy) {
                                browserManager.deleteTab(tab)
                                deleteHapticTrigger.toggle()
                            }
                        },
                        onSelect: {
                            browserManager.switchToTab(tab)
                            dismiss()
                        }
                    )
                }
            }
            .padding()
            .padding(.bottom, 60)
        }
        .background {
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.05, blue: 0.18),
                    Color(red: 0.42, green: 0.24, blue: 0.36),
                    Color(red: 0.28, green: 0.20, blue: 0.46)
                ],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .ignoresSafeArea()
        }
    }

    private var bottomToolbar: some View {
        var tabSectionBinding: Binding<TabType> {
            Binding(
                get: { tabsManager.tabSection },
                set: { tabsManager.tabSection = $0 }
            )
        }

        return HStack {
            Button {
                browserManager.createNewTab()
                dismiss()
            } label: {
                Image(systemName: "plus")
                    .font(.title)
                    .foregroundStyle(.white)
                    .padding(14)
                    .glassEffect(.clear.interactive(), in: .circle)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 20)

            Picker("Private/Regular Tabs", selection: tabSectionBinding) {
                Text("Private").tag(TabType.privateTabs)
                Text("\(regularTabCount) Tabs").tag(TabType.regularTabs)
            }
            .frame(height: 50)
            .pickerStyle(.segmented)
            .controlSize(.extraLarge)
            .glassEffect(.regular.interactive())

            Spacer(minLength: 20)

            Button {
                dismiss()
            } label: {
                Image(systemName: "checkmark")
                    .font(.title)
                    .foregroundStyle(.white)
                    .padding(14)
                    .glassEffect(.regular.tint(.blue).interactive(), in: .circle)
            }
            .buttonStyle(.plain)
        }
    }

    private var regularTabCount: Int {
        tabs.filter { !$0.isPrivate }.count
    }
}

#Preview {
    TabsViewer()
        .environment(BrowserManager())
        .environment(TabsManager())
        .modelContainer(for: [BrowserTab.self])
}
