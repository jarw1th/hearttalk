//
//  OnlineProfilePreview.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 30.01.2025.
//

import SwiftUI

struct OnlineProfilePreview: View {
    
    var image: URL?
    var name: String
    var maxWidth: CGFloat? = nil
    var tapAction: () -> Void
    
    var body: some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            tapAction()
        } label: {
            HStack(spacing: 16) {
                AsyncImage(url: image, content: { image in
                    image
                        .resizable()
                        .frame(width: 36, height: 36)
                        .cornerRadius(12)
                }, placeholder: {
                    EmptyView()
                })
                Text(name)
                    .font(.custom("Poppins-Regular", size: 16))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.lightBlack)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(3)
            .frame(width: maxWidth != nil ? nil : 280, height: 42)
            .frame(maxWidth: maxWidth, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.darkWhite)
            )
        }
    }
    
}

