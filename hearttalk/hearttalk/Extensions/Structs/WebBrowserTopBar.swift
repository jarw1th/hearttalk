//
//  WebBrowserTopBar.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 31.01.2025.
//

import SwiftUI

struct WebBrowserTopBar: View {
    
    var text: String
    var canGoBack: Bool
    var canGoForward: Bool
    var closeTapAction: () -> Void
    var backTapAction: () -> Void
    var forwardTapAction: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Text(text)
                .font(.custom("Poppins-Regular", size: 24))
                .multilineTextAlignment(.leading)
                .foregroundStyle(.darkWhite)
                .lineLimit(1)
            Spacer()
            Button {
                HapticManager.shared.triggerHapticFeedback(.light)
                SoundManager.shared.sound(.click1)
                backTapAction()
            } label: {
                Icon(name: "back")
            }
            .disabled(!canGoBack)
            .opacity(canGoBack ? 1 : 0.5)
            Button {
                HapticManager.shared.triggerHapticFeedback(.light)
                SoundManager.shared.sound(.click1)
                forwardTapAction()
            } label: {
                Icon(name: "forward")
            }
            .disabled(!canGoForward)
            .opacity(canGoForward ? 1 : 0.5)
            Button {
                HapticManager.shared.triggerHapticFeedback(.light)
                SoundManager.shared.sound(.click1)
                closeTapAction()
            } label: {
                Icon(name: "cross")
            }
        }
    }
    
}
