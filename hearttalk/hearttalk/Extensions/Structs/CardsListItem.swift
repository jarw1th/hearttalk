//
//  CardsList.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 29.01.2025.
//

import SwiftUI

struct CardsListItem: View {
    
    let index: Int
    let question: String
    var isSelected: Bool
    var tapAction: () -> Void
    
    var body: some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            tapAction()
        } label: {
            HStack(alignment: .top, spacing: 20) {
                Text("#\(index + 1)")
                    .font(.custom("Poppins-Regular", size: 20))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.lightBlack)
                    .opacity(isSelected ? 1 : 0.5)
                Text(question)
                    .font(.custom("Poppins-Regular", size: 20))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.lightBlack)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(isSelected ? 1 : 0.5)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.darkWhite)
            )
        }
    }
    
}
