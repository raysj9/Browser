import SwiftUI

struct FindInPageBar: View {
    @Environment(BrowserManager.self) private var browser
    @FocusState private var searchIsFocused: Bool
    @State private var query: String = ""

    var body: some View {
        GlassEffectContainer(spacing: 12) {
            VStack(spacing: 12) {
                TextField("Find in Page", text: $query)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .focused($searchIsFocused)
                    .submitLabel(.search)
                    .onSubmit {
                        browser.updateFindInPageQuery(query)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .glassEffect(.regular, in: .rect(cornerRadius: 12))

                if !query.isEmpty && !browser.findInPageMatchFound {
                    Text("No matches")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 12) {
                    Button {
                        browser.findInPagePrevious()
                    } label: {
                        Label("Previous", systemImage: "chevron.up")
                    }
                    .buttonStyle(.glass(.clear))
                    .disabled(query.isEmpty)

                    Button {
                        browser.findInPageNext()
                    } label: {
                        Label("Next", systemImage: "chevron.down")
                    }
                    .buttonStyle(.glass(.clear))
                    .disabled(query.isEmpty)

                    Spacer()

                    Button("Done") {
                        browser.isPresentingFindInPageSheet = false
                    }
                    .buttonStyle(.glass(.regular))
                }
            }
            .padding(16)
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 18))
        }
        .onAppear {
            query = browser.findInPageQuery
            browser.updateFindInPageQuery(query)
            searchIsFocused = true
        }
        .onChange(of: query) { _, newValue in
            browser.updateFindInPageQuery(newValue)
        }
    }
}

#Preview {
    FindInPageBar()
        .environment(BrowserManager())
}
