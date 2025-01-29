//
//  SettingsValueButton.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 29.01.2025.
//

import SwiftUI

struct SettingsValueButton: View {
    
    var text: String
    var selectedItem: String
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
                
                Text(selectedItem)
                    .font(.custom("Poppins-Regular", size: 16))
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.darkWhite)
            }
        }
    }
    
}
