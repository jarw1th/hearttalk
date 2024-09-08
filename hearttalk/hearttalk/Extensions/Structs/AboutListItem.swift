
import SwiftUI

struct AboutListItem: View {
    
    let imageName: String
    let text: String
    let isSpecial: Bool
    let action: () -> Void
    
    var body: some View {
        makeContent()
    }
    
    private func makeContent() -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            action()
        } label: {
            HStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32) {
                Image(imageName)
                    .renderingMode(.template)
                    .resizable()
                    .foregroundStyle(isSpecial ? .darkWhite : .lightBlack)
                    .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48, height: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48)
                Text(text)
                    .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(isSpecial ? .darkWhite : .lightBlack)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32)
            .padding(.vertical, UIDevice.current.userInterfaceIdiom == .phone ? 12 : 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSpecial ? .darkGreen : .darkWhite)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSpecial ? .darkWhite : .clear)
            )
        }
    }
    
}
