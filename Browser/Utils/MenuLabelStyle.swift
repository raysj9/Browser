//
//  MenuLabelStyle.swift
//  Browser
//

import SwiftUI

struct MenuLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            
            Spacer()
            
            configuration.icon
        }
    }
}

extension LabelStyle where Self == MenuLabelStyle {
    static var menu: MenuLabelStyle {
        MenuLabelStyle()
    }
}
