//
//  LoginButton.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 05.02.2025.
//

import SwiftUI

struct LoginButton: View {
    
    var tapAction: () -> Void
    
    var body: some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            tapAction()
        } label: {
            Text(Localization.logIn)
                .font(.custom("Poppins-Regular", size: 16))
                .multilineTextAlignment(.leading)
                .foregroundStyle(.lightBlack)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .frame(height: 46)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.darkWhite)
                        .opacity(0.5)
                )
        }
    }
    
}
