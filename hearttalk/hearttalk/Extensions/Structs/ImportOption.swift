//
//  ImportOption.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 31.01.2025.
//

import SwiftUI

struct ImportOption: View {
    
    var text: String
    var isImported: Bool
    var tapAction: () -> Void
    var closeTapAction: () -> Void
    var tipTapAction: () -> Void
    
    @ViewBuilder
    var body: some View {
        if isImported {
            HStack {
                Text(text)
                    .font(.custom("Poppins-Regular", size: 16))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.darkWhite)
                Spacer()
                Button {
                    HapticManager.shared.triggerHapticFeedback(.light)
                    SoundManager.shared.sound(.click1)
                    closeTapAction()
                } label: {
                    Icon(name: "cross", size: .custom(20))
                }
            }
        } else {
            Button {
                HapticManager.shared.triggerHapticFeedback(.light)
                SoundManager.shared.sound(.click1)
                tapAction()
            } label: {
                HStack(spacing: 16) {
                    Text(text)
                        .font(.custom("Poppins-Regular", size: 16))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.darkWhite)
                    Spacer()
                    Button {
                        HapticManager.shared.triggerHapticFeedback(.light)
                        SoundManager.shared.sound(.click1)
                        tipTapAction()
                    } label: {
                        Icon(name: "question", size: .custom(20))
                    }
                    Icon(name: "rightArrow", size: .custom(20))
                }
            }
        }
    }
    
}
