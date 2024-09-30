
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
        makeContent()
    }
    
    private func makeContent() -> some View {
        VStack(alignment: .leading, spacing: UIDevice.current.userInterfaceIdiom == .phone ? 8 : 16) {
            Text(Localization.color)
                .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                .foregroundColor(.darkWhite)
                .multilineTextAlignment(.leading)
                .padding(.leading, UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32)
            
            LazyVGrid(columns: columns, spacing: UIDevice.current.userInterfaceIdiom == .phone ? 8 : 16) {
                ForEach(colors, id: \.self) { color in
                    makeRectangle(color)
                }
            }
        }
    }
    
    private func makeRectangle(_ color: Color) -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            self.color = color
        } label: {
            RoundedRectangle(cornerRadius: 20)
                .fill(color)
                .overlay(  
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(self.color == color ? Color(white: 1.0) : .clear, lineWidth: 2)
                )
                .frame(width: 48, height: 48)
        }
    }
    
}
