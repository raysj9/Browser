import SwiftUI
import WebKit

struct BrowserView: View {
    @Environment(BrowserManager.self) private var manager
    @Environment(AppSettings.self) private var appSettings
    @Environment(ToastManager.self) private var toastManager
    @Environment(\.modelContext) private var context
    @State private var toolbarHeight: CGFloat = 0
    @State private var addressBarHeight: CGFloat = 0
    @Namespace private var tabsTransitionNamespace

    var body: some View {
        @Bindable var managerBinding = manager
        @Bindable var settingsBinding = appSettings
        @Bindable var toastBinding = toastManager
        
        NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    WebView(
                        webView: manager.webView,
                        topContentInset: addressBarHeight,
                        bottomContentInset: toolbarHeight
                    )
                        .ignoresSafeArea()

                    VStack(spacing: 0) {
                        AddressBarView()
                            .frame(maxWidth: .infinity)
                            .background {
                                Rectangle()
                                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 0))
                                    .ignoresSafeArea(edges: .top)
                                    .allowsHitTesting(false)
                            }
                            .background(
                                GeometryReader { addressBarGeometry in
                                    Color.clear
                                        .onAppear {
                                            addressBarHeight = addressBarGeometry.size.height
                                        }
                                        .onChange(of: addressBarGeometry.size.height) { _, newValue in
                                            addressBarHeight = newValue
                                        }
                                }
                            )

                        Spacer()

                        ToolbarView(tabsTransitionNamespace: tabsTransitionNamespace)
                            .frame(maxWidth: .infinity)
                            .background {
                                Rectangle()
                                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 0))
                                    .ignoresSafeArea(edges: .bottom)
                                    .allowsHitTesting(false)
                            }
                            .background(
                                GeometryReader { toolbarGeometry in
                                    Color.clear
                                        .onAppear {
                                            toolbarHeight = toolbarGeometry.size.height
                                        }
                                        .onChange(of: toolbarGeometry.size.height) { _, newValue in
                                            toolbarHeight = newValue
                                        }
                                }
                            )
                    }

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
