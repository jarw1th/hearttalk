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
    var tapAction: () -> Void
    
    var body: some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            tapAction()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.darkWhite)
                
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
                }
                .padding(3)
            }
            .frame(width: 200, height: 46)
        }
    }
    
}

