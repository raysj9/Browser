import SwiftUI
import WebKit

struct BrowserView: View {
    @Environment(BrowserManager.self) private var manager
    @Environment(AppSettings.self) private var appSettings
    @Environment(ToastManager.self) private var toastManager
    @Environment(\.modelContext) private var context
    @State private var toolbarHeight: CGFloat = 0
    @Namespace private var tabsTransitionNamespace

    var body: some View {
        @Bindable var managerBinding = manager
        @Bindable var settingsBinding = appSettings
        @Bindable var toastBinding = toastManager
        
        NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    WebView(webView: manager.webView, topContentInset: geometry.safeAreaInsets.top - 10)
                        .ignoresSafeArea()

                    VStack(spacing: 0) {
                        AddressBarView()
                            .padding(.horizontal, 30)
                            .background(
                                GeometryReader { addressBarGeometry in
                                    Color.clear
                                        .onAppear {
                                            // Calculate total offset needed to move address bar completely off-screen
                                            let addressBarHeight = addressBarGeometry.size.height
                                            let topSafeArea = geometry.safeAreaInsets.top
                                            manager.setAddressBarHideOffset(-(addressBarHeight + topSafeArea))
                                        }
                                }
                            )
                            .offset(y: manager.addressBarOffset)

                        Spacer()
                    
                        ToolbarView(tabsTransitionNamespace: tabsTransitionNamespace)
                            .padding(.horizontal, 30)
                            .background(
                                GeometryReader { toolbarGeometry in
                                    Color.clear
                                        .onAppear {
                                            // Calculate total offset needed to move toolbar completely off-screen
                                            let toolbarHeight = toolbarGeometry.size.height
                                            let bottomSafeArea = geometry.safeAreaInsets.bottom
                                            manager.setToolbarHideOffset(toolbarHeight + bottomSafeArea)
                                            self.toolbarHeight = toolbarHeight
                                        }
                                        .onChange(of: toolbarGeometry.size.height) { _, newValue in
                                            self.toolbarHeight = newValue
                                        }
                                }
                            )
                            .offset(y: manager.toolbarOffset)
                    }
                    .padding(.bottom)
                    .ignoresSafeArea(edges: .bottom)

                    if let toast = toastBinding.toast {
                        ToastView(toast: toast)
                            .padding(.horizontal, 24)
                            .padding(.bottom, geometry.safeAreaInsets.bottom + toolbarHeight)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .onTapGesture {
                                toast.action?()
                                toastBinding.dismiss()
                            }
                            .zIndex(1)
                    }
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
