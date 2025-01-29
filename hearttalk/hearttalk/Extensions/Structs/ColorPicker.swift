
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
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
                .overlay(  
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(self.color == color ? Color(white: 1.0) : .clear, lineWidth: 2)
                )
                .frame(width: 48, height: 48)
        }
    }
    
}
