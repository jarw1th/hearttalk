//
//  OnlinePreviewCard.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 30.01.2025.
//

import SwiftUI

struct OnlinePreviewCard: View {
    
    var favorites: FirebasePack
    var question: Card
    var height: CGFloat = 140
    var maxWidth: CGFloat? = nil
    var tapAction: () -> Void
    
    var body: some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            tapAction()
        } label: {
            Text(question.question)
                .font(.custom("Poppins-Regular", size: 12))
                .multilineTextAlignment(.leading)
                .foregroundStyle(.lightBlack)
                .frame(width: maxWidth != nil ? nil : 120, height: height)
                .frame(maxWidth: maxWidth)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white)
                        .opacity(favorites.pack.cards.contains(question) ? 1 : 0.5)
                )
        }
    }
    
}

