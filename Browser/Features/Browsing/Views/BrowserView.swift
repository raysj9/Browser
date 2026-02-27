import SwiftUI
struct BrowserView: View {
    @Environment(BrowserManager.self) private var manager
    @Environment(AppSettings.self) private var appSettings
    @Environment(TabsManager.self) private var tabsManager
    @Environment(ToastManager.self) private var toastManager
    @Environment(\.modelContext) private var context
    @Namespace private var tabsTransitionNamespace

    var body: some View {
        @Bindable var managerBinding = manager
        @Bindable var toastBinding = toastManager
        
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    AddressBarView()
                        .frame(maxWidth: .infinity)

                    WebView(
                        webView: manager.webView
                    )

                    ToolbarView(tabsTransitionNamespace: tabsTransitionNamespace)
                        .frame(maxWidth: .infinity)
                }

                if managerBinding.isPresentingFindInPageSheet {
                    FindInPageBar()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 88)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(2)
                }

                if let toast = toastBinding.toast {
                    ToastView(toast: toast)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onTapGesture {
                            toast.action?()
                            toastBinding.dismiss()
                        }
                        .zIndex(1)
                }
            }
            .navigationDestination(isPresented: $managerBinding.isPresentingTabsView) {
                TabsViewer()
                    .navigationTransition(.zoom(sourceID: "tabs-button", in: tabsTransitionNamespace))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.9), value: toastBinding.toast?.id)
        .sheet(isPresented: $managerBinding.isPresentingHistorySheet, content: {
            NavigationStack {
                HistoryView()
            }
        })
        .sheet(isPresented: $managerBinding.isPresentingBookmarksSheet, content: {
            NavigationStack {
                BookmarksView()
            }
        })
        .sheet(isPresented: $managerBinding.isPresentingSummarySheet, content: {
            AISummarySheet()
                .presentationDetents([.medium, .large])
                .presentationBackgroundInteraction(.enabled)
        })
        .sheet(isPresented: $managerBinding.isPresentingPageMenuSheet, content: {
            PageMenuSheet()
                .presentationDetents([.fraction(0.5)])
        })
        .sheet(isPresented: $managerBinding.isPresentingSettingsSheet, content: {
            SettingsView()
        })
        .task {
            manager.context = context
            manager.appSettings = appSettings
            manager.tabsManager = tabsManager
            manager.loadInitialTabIfNeeded()
        }
    }
}

#Preview {
    BrowserView()
        .environment(BrowserManager())
        .environment(AppSettings())
        .environment(ToastManager())
}
