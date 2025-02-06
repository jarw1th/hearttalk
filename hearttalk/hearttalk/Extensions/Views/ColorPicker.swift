//
//  Untitled.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 29.01.2025.
//

import SwiftUI

struct ColorPicker: View {
    
    let colors: [Color]
    @Binding var color: Color
    
    private let columns = [
        GridItem(.flexible(), spacing: UIDevice.current.userInterfaceIdiom == .phone ? 8 : 16),
        GridItem(.flexible(), spacing: UIDevice.current.userInterfaceIdiom == .phone ? 8 : 16),
        GridItem(.flexible(), spacing: UIDevice.current.userInterfaceIdiom == .phone ? 8 : 16),
        GridItem(.flexible(), spacing: UIDevice.current.userInterfaceIdiom == .phone ? 8 : 16),
        GridItem(.flexible(), spacing: UIDevice.current.userInterfaceIdiom == .phone ? 8 : 16)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: UIDevice.current.userInterfaceIdiom == .phone ? 8 : 16) {
            ForEach(colors, id: \.self) { color in
                makeRectangle(color)
            }
        }
    }
    
    private func makeRectangle(_ color: Color) -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            self.color = color
        } label: {
            ZStack {
                Rectangle()
                    .fill(.clear)
                    .frame(width: 48, height: 48)
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
                    .frame(width: self.color == color ? 24 : 48, height: self.color == color ? 24 : 48)
                    
            }
        }
    }
    
}
