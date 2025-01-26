//
//  SettingsListItem.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 24.01.2025.
//

import SwiftUI

struct SettingsListItem: View {
    
    var imageName: String
    var text: String
    var isSpecial: Bool
    var action: () -> Void
    
    var body: some View {
        makeContent()
    }
    
    private func makeContent() -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            action()
        } label: {
            HStack(alignment: .top, spacing: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32) {
                Image(imageName)
                    .renderingMode(.template)
                    .resizable()
                    .foregroundStyle(isSpecial ? .darkWhite : .lightGray)
                    .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 40, height: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 40)
                Text(text)
                    .font(.custom("PlayfairDisplay-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 20))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(isSpecial ? .darkWhite : .lightBlack)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32)
            .padding(.vertical, UIDevice.current.userInterfaceIdiom == .phone ? 12 : 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSpecial ? .darkGreen : .darkWhite)
            )
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSpecial ? .darkWhite : .clear, lineWidth: 1)
            )
        }
    }
    
}

struct SettingsToggler: View {
    
    var text: String
    @Binding var isOn: Bool
    
    var body: some View {
        makeContent()
    }
    
    private func makeContent() -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            isOn.toggle()
        } label: {
            HStack(alignment: .top, spacing: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32) {
                Image(isOn ? "on" : "off")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundStyle(.lightGray)
                    .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 40, height: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 40)
                Text(text)
                    .font(.custom("PlayfairDisplay-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 20))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.lightBlack)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32)
            .padding(.vertical, UIDevice.current.userInterfaceIdiom == .phone ? 12 : 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.darkWhite)
                    .opacity(isOn ? 1 : 0.6)
            )
        }
    }
    
}
