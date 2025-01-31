//
//  BackTopBar.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 29.01.2025.
//

import SwiftUI

struct BackTopBar<Content: View>: View {
    
    var text: String
    var isEdit: Bool
    var isSelected: Bool
    var selectTapAction: () -> Void
    var deleteTapAction: () -> Void
    var optionButtons: () -> Content
    var closeTapAction: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Button {
                HapticManager.shared.triggerHapticFeedback(.light)
                SoundManager.shared.sound(.click1)
                selectTapAction()
            } label: {
                let text = isEdit ? (isSelected ? Localization.deselectAll : Localization.selectAll) : text
                Text(text)
                    .font(.custom("Poppins-Regular", size: 24))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.darkWhite)
                    .lineLimit(1)
            }
            .disabled(!isEdit)
            Spacer()
            if isEdit {
                Button {
                    HapticManager.shared.triggerHapticFeedback(.light)
                    SoundManager.shared.sound(.click1)
                    deleteTapAction()
                } label: {
                    Icon(name: "trash", color: .destruct)
                }
            } else {
                Menu {
                    optionButtons()
                } label: {
                    Icon(name: "option")
                }
            }
            Button {
                HapticManager.shared.triggerHapticFeedback(.light)
                SoundManager.shared.sound(.click1)
                closeTapAction()
            } label: {
                Icon(name: "cross")
            }
        }
    }
    
}
