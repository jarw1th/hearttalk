//
//  OnlineProfile.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 31.01.2025.
//

import SwiftUI

struct OnlineProfile: View {
    
    var image: URL?
    var name: String
    var tapAction: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: image, content: { image in
                image
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(12)
            }, placeholder: {
                
            })
            Text(name)
                .font(.custom("Poppins-Regular", size: 16))
                .multilineTextAlignment(.leading)
                .foregroundStyle(.lightBlack)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            Button {
                HapticManager.shared.triggerHapticFeedback(.light)
                SoundManager.shared.sound(.click1)
                tapAction()
            } label: {
                Text(Localization.logOut)
                    .font(.custom("Poppins-Regular", size: 16))
                    .foregroundStyle(.destruct)
            }
            .padding(.trailing, 9)
        }
        .padding(3)
        .frame(height: 46)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.darkWhite)
        )
    }
    
}

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

