//
//  OnlinePreviewPack.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 30.01.2025.
//

import SwiftUI

struct OnlinePreviewPack: View {
    
    var pack: FirebasePack
    var tapAction: () -> Void
    
    var body: some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            tapAction()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: pack.pack.color), lineWidth: 2)
                    .frame(width: 200, height: 140)
                
                VStack(alignment: .leading) {
                    Text(pack.pack.name)
                        .font(.custom("Poppins-Regular", size: 16))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(Color(hex: pack.pack.color))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    HStack(alignment: .bottom, spacing: 12) {
                        let txt = (pack.cards == 1 ? Localization.card : Localization.cards)
                        Text(pack.cards == 0 ? Localization.empty : "\(pack.cards) \(txt)")
                            .font(.custom("Poppins-Regular", size: 12))
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.darkWhite)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        let hashtags = pack.tags.map({ "#\($0)" })
                        let text = hashtags.joined(separator: " ")
                        Text(text)
                            .font(.custom("Poppins-Regular", size: 12))
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(.darkWhite)
                    }
                }
                .padding(16)
            }
            .frame(width: 200, height: 142)
        }
    }
    
}

