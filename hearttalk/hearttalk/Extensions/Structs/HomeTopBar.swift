//
//  HomeTopBar.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 29.01.2025.
//

import SwiftUI

struct HomeTopBar: View {
    
    var text: String
    var tapAction: () -> Void
    
    var body: some View {
        HStack {
            Text(text)
                .font(.custom("Poppins-Regular", size: 24))
                .multilineTextAlignment(.leading)
                .foregroundStyle(.darkWhite)
                .lineLimit(1)
            Spacer()
            Button {
                HapticManager.shared.triggerHapticFeedback(.light)
                SoundManager.shared.sound(.click1)
                tapAction()
            } label: {
                Icon(name: "settings")
            }
        }
    }
    
}
