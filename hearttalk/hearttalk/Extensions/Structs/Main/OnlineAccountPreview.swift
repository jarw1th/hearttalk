
import SwiftUI

struct OnlineAccountPreview: View {
    
    var photoURL: URL?
    var name: String?
    var tapAction: () -> Void
    
    var body: some View {
        ZStack {
            HStack(spacing: 16) {
                AsyncImage(url: photoURL) { image in
                    image
                        .resizable()
                        .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 36, height: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 36)
                        .clipped()
                        .clipShape(Circle())
                } placeholder: {
                    VStack {
                        Image("profile")
                            .renderingMode(.template)
                            .resizable()
                            .foregroundStyle(.darkWhite)
                            .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32, height: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32)
                    }
                    .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 36, height: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 36)
                }
                Text(name ?? "Incognito")
                    .font(.custom("PlayfairDisplay-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.darkWhite)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                Button {
                    HapticManager.shared.triggerHapticFeedback(.light)
                    SoundManager.shared.sound(.click1)
                    tapAction()
                } label: {
                    Text("Show")
                        .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32))
                        .underline()
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(.darkGreen)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 40)
    }
    
}
