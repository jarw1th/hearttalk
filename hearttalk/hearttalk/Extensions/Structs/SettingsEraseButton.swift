//
//  SettingsEraseButton.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 29.01.2025.
//

import SwiftUI

struct SettingsEraseButton: View {
    
    var text: String
    var buttonTitle: String = "Clear all"
    var tapAction: () -> Void
    
    var body: some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            tapAction()
        } label: {
            HStack {
                Text(text)
                    .font(.custom("Poppins-Regular", size: 16))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.darkWhite)
                Spacer()
                Text(buttonTitle)
                    .font(.custom("Poppins-Regular", size: 16))
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.destruct)
            }
        }
    }
    
}
