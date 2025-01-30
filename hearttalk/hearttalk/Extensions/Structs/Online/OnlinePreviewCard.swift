//
//  OnlinePreviewCard.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 30.01.2025.
//

import SwiftUI

struct OnlinePreviewCard: View {
    
    var isLiked: Bool
    var question: String
    var tapAction: () -> Void
    
    var body: some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            tapAction()
        } label: {
            Text(question)
                .font(.custom("Poppins-Regular", size: 12))
                .multilineTextAlignment(.leading)
                .foregroundStyle(.lightBlack)
                .opacity(isLiked ? 1 : 0.7)
                .frame(width: 120, height: 140)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.darkWhite)
                        .opacity(isLiked ? 1 : 0.7)
                )
        }
    }
    
}

