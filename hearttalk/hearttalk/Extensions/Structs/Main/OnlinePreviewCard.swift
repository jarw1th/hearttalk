
import SwiftUI

struct OnlinePreviewCard: View {
    
    var card: Card
    var isAdded: Bool
    var tapAction: () -> Void
    
    var body: some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            tapAction()
        } label: {
            ZStack {
                VStack {
                    HStack {
                        Spacer()
                        Image("plus")
                            .renderingMode(.template)
                            .resizable()
                            .foregroundStyle(isAdded ? .destruct : .darkGreen)
                            .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24, height: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24)
                            .rotationEffect(Angle(degrees: isAdded ? 45 : 0))
                            .animation(.easeInOut, value: isAdded)
                    }
                    Spacer()
                }
                .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24)
                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24)
                VStack {
                    Spacer()
                    Text(card.question)
                        .font(.custom("PlayfairDisplay-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 10 : 18))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.lightBlack)
                        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24)
                    Spacer()
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.darkWhite)
                )
            }
            .frame(maxWidth: .infinity, maxHeight: 180)
        }
    }
    
}
