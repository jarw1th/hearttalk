
import SwiftUI

struct ListItem: View {
    
    let number: Int
    let question: String
    let action: () -> Void
    
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
                Text("#\(number)")
                    .font(.custom("PlayfairDisplay-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 32))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.lightBlack)
                Text(question)
                    .font(.custom("PlayfairDisplay-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 32))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.lightBlack)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 32)
            .padding(.vertical, UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.darkWhite)
            )
        }
    }
    
}
