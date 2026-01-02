// WIP

import SwiftUI

struct TabsViewer: View {
    @Environment(TabsManager.self) private var tabsManager

    var body: some View {
        ZStack {
            tabsView

            VStack {
                Spacer()

                bottomToolbar
                    .padding(.horizontal)
            }
        }
    }

    private var tabsView: some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        return ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(tabsManager.tabs) { tab in
                    TabPreviewCard(tab: tab) {
                        withAnimation(.snappy) {
                            tabsManager.delete(tab)
                        }
                    }
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
                Text("\(tabsManager.tabs.count) Tabs").tag(TabType.regularTabs)
            }
            .frame(height: 50)
            .pickerStyle(.segmented)
            .controlSize(.extraLarge)
            .glassEffect(.regular.interactive())

            Spacer(minLength: 20)

            Button {

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
}

#Preview {
    TabsViewer()
        .environment(TabsManager())
}
