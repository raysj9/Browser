// WIP

import SwiftUI

@Observable
class TabsManager {
    var tabs: [BrowserTab] = BrowserTab.sample
    var tabSection: TabType = .regularTabs

    func delete(_ tab: BrowserTab) {
        tabs.removeAll { $0.id == tab.id }
    }
}
