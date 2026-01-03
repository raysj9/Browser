import SwiftUI
import WebKit
import FoundationModels

struct AddressBarView: View {
    @Environment(BrowserManager.self) private var browser
    @Environment(AppSettings.self) private var appSettings

    @FocusState private var isFieldFocused: Bool
    @Namespace private var namespace

    private var urlBinding: Binding<String> {
        Binding(
            get: { browser.urlString },
            set: { browser.urlString = $0 }
        )
    }

    var body: some View {
        GlassEffectContainer(spacing: 12) {
            HStack(spacing: 12) {
                HStack {
                    if !browser.addressBarIsActive && supportsFoundationModels {
                        summaryButton
                    }

                    Spacer()

                    if browser.addressBarIsActive {
                        addressTextField
                    } else {
                        addressText
                    }

                    Spacer()
                    
                    if browser.addressBarIsActive {
                        clearAddressBarTextButton
                    } else {
                        refreshButton
                    }

                }
                .background(TouchBlockingView())
                .padding(.horizontal)
                .padding(.vertical)
                .glassEffect(.regular.interactive())
                .glassEffectID("navigationbar", in: namespace)
                                
                if browser.addressBarIsActive {
                    cancelButton
                }
            }
            .contentShape(Rectangle())
            .onChange(of: browser.addressBarIsActive) { _, active in
                if active {
                    isFieldFocused = true
                } else {
                    isFieldFocused = false
                }
            }
        }

    }
    
    var addressTextField: some View {
        TextField("", text: urlBinding)
            .fontWeight(.semibold)
            .keyboardType(.webSearch)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused($isFieldFocused)
            .onAppear {
                isFieldFocused = true
            }
            .onSubmit {
                browser.addressBarIsActive = false
                isFieldFocused = false

                let url = browser.urlFromUserInput(browser.urlString)
                browser.load(url: url)
            }
    }
    
    var addressText: some View {
        Text(browser.urlString.isEmpty ? "Search or enter website name" : browser.urlString)
            .fontWeight(.semibold)
            .lineLimit(1)
            .contentShape(Rectangle())
            .onTapGesture {
                browser.showAddressBar()
                browser.addressBarIsActive = true
                isFieldFocused = true
            }
    }
    
    var clearAddressBarTextButton: some View {
        Button {
            browser.urlString = ""
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.title3)
        }
        .buttonStyle(.plain)
    }
    
    var refreshButton: some View {
        Group {
            if browser.isLoading {
                ProgressView(value: browser.estimatedProgress)
                    .progressViewStyle(.circular)
            } else {
                Button {
                    browser.refreshPage()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.plain)
            }
        }
    }

    var summaryButton: some View {
        Button {
            browser.isPresentingSummarySheet = true
        } label: {
            Image(systemName: "sparkles")
                .foregroundStyle(.yellow)
        }
        .buttonStyle(.plain)
    }

    private var supportsFoundationModels: Bool {
        appSettings.aiFeaturesEnabled && SystemLanguageModel.default.availability == .available
    }
    
    var cancelButton: some View {
        Button {
            withAnimation {
                browser.addressBarIsActive.toggle()
            }
        } label: {
            Image(systemName: "xmark")
                .padding()
        }
        .buttonStyle(.plain)
        .glassEffect(.regular, in: .circle)
        .glassEffectID("xmark", in: namespace)
        .glassEffectTransition(.materialize)
    }
}

#Preview {
    BrowserView()
        .environment(BrowserManager())
}
