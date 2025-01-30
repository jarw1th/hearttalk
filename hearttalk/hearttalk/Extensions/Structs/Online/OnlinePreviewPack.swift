//
//  OnlinePreviewPack.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 30.01.2025.
//

import SwiftUI

struct OnlinePreviewPack: View {
    
    var color: String
    var name: String
    var tags: [String]
    var tapAction: () -> Void
    
    var body: some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            tapAction()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: color))
                
                VStack(alignment: .leading) {
                    Text(name)
                        .font(.custom("Poppins-Regular", size: 16))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.darkWhite)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    let hashtags = tags.map({ "#\($0)" })
                    let text = hashtags.joined(separator: " ")
                    Text(text)
                        .font(.custom("Poppins-Regular", size: 12))
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(.darkWhite)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16)
            }
            .frame(width: 200, height: 140)
        }
    }
    
}

