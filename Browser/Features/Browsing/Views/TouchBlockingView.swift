//
//  TouchBlockingView.swift
//  Browser
//

import SwiftUI

/// A transparent view that *still intercepts touches*.
/// Useful when overlaying controls on top of a `WKWebView` to prevent "click-through"
/// without adding extra SwiftUI gesture recognizers.
struct TouchBlockingView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let v = UIView(frame: .zero)
        v.backgroundColor = .clear
        v.isUserInteractionEnabled = true
        return v
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}


