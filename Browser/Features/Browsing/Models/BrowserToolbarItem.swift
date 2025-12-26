//
//  BrowserToolbarItem.swift
//  Browser
//

enum BrowserToolbarItem: CaseIterable {
    case back
    case forward
    case newTab
    case menu
    case tabs

    var systemImage: String {
        switch self {
        case .back: "chevron.left"
        case .forward: "chevron.right"
        case .newTab: "plus"
        case .menu: "ellipsis"
        case .tabs: "square.on.square"
        }
    }

    var action: Action {
        switch self {
        case .back: .goBack
        case .forward: .goForward
        case .newTab: .newTab
        case .menu: .openMenu
        case .tabs: .showTabs
        }
    }

    enum Action {
        case goBack
        case goForward
        case newTab
        case openMenu
        case showTabs
    }
}
