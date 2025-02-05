//
//  SearchBar.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 29.01.2025.
//

import SwiftUI

struct SearchBar: View {
    
    let placeholder: String
    @Binding var text: String
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            if !isFocused {
                Icon(name: "search", size: .custom(16), color: .darkWhite.opacity(0.5))
            }
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.custom("Poppins-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                        .foregroundColor(.darkWhite)
                        .opacity(0.5)
                }
                TextField("", text: $text)
                    .autocapitalization(.sentences)
                    .disableAutocorrection(true)
                    .font(.custom("Poppins-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                    .foregroundStyle(.darkWhite)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .focused($isFocused)
            }
            if isFocused {
                Button {
                    HapticManager.shared.triggerHapticFeedback(.light)
                    SoundManager.shared.sound(.click1)
                    text = ""
                    isFocused = false
                } label: {
                    Icon(name: "cross", size: .custom(16), color: .destruct)
                }
            }
        }
        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32)
        .padding(.vertical, UIDevice.current.userInterfaceIdiom == .phone ? 8 : 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.darkWhite, lineWidth: 1)
                .opacity(text.isEmpty ? 0.5 : 1)
        )
    }
    
}
