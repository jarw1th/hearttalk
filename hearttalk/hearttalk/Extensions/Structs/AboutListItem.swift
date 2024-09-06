
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
            HStack(spacing: 24) {
                Image(imageName)
                    .renderingMode(.template)
                    .resizable()
                    .foregroundStyle(isSpecial ? .darkWhite : .lightBlack)
                    .frame(width: 24, height: 24)
                Text(text)
                    .font(.custom("PlayfairDisplay-Regular", size: 16))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(isSpecial ? .darkWhite : .lightBlack)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
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
