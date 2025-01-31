//
//  DrawingView.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 29.01.2025.
//

import SwiftUI

struct NoteImageField: View {
    
    var image: UIImage
    var onClear: () -> Void
    var onChange: () -> Void
    var onCrop: () -> Void
    
    var body: some View {
        ZStack {
            Menu {
                Button {
                    HapticManager.shared.triggerHapticFeedback(.light)
                    SoundManager.shared.sound(.click1)
                    onChange()
                } label: {
                    Text(Localization.change)
                }
                Button {
                    HapticManager.shared.triggerHapticFeedback(.light)
                    SoundManager.shared.sound(.click1)
                    onCrop()
                } label: {
                    Text(Localization.crop)
                }
            } label: {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        HapticManager.shared.triggerHapticFeedback(.light)
                        SoundManager.shared.sound(.click1)
                        onClear()
                    } label: {
                        Icon(name: "cross", size: .custom(20), color: .destruct)
                    }
                }
                Spacer()
            }
            .padding(16)
        }
        .frame(height: 180)
        .frame(maxWidth: .infinity)
    }
    
}
