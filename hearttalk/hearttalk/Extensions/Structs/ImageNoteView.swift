//
//  ImageNoteView.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 29.01.2025.
//

import SwiftUI

struct ImageNoteView: View {
    
    let image: UIImage
    var isSelected: Bool
    var tapAction: () -> Void
    
    var body: some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            tapAction()
        } label: {
            Image(uiImage: image)
                .resizable()
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .cornerRadius(12)
                .opacity(isSelected ? 1 : 0.5)
        }
    }
    
}
