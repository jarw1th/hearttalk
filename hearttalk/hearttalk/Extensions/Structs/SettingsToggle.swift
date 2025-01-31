//
//  SettingsToggle.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 29.01.2025.
//

import SwiftUI

struct SettingsToggle: View {
    
    var text: String
    @Binding var isOn: Bool
    
    var body: some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            isOn.toggle()
        } label: {
            HStack {
                Text(text)
                    .font(.custom("Poppins-Regular", size: 16))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.darkWhite)
                    .opacity(isOn ? 1 : 0.5)
                Spacer()
                Text(isOn ? Localization.on : Localization.off)
                    .font(.custom("Poppins-Regular", size: 16))
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.darkWhite)
                    .opacity(isOn ? 1 : 0.5)
            }
        }
    }
    
}
