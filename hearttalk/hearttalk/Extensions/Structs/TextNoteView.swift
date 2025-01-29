//
//  TextNoteView.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 29.01.2025.
//

import SwiftUI

struct TextNoteView: View {
    
    let text: String
    var isSelected: Bool
    var tapAction: () -> Void
    
    var body: some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            tapAction()
        } label: {
            Text(text)
                .font(.custom("Poppins-Regular", size: 20))
                .multilineTextAlignment(.leading)
                .foregroundStyle(.lightBlack)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.darkWhite)
                )
                .opacity(isSelected ? 1 : 0.5)
        }
    }
    
}
