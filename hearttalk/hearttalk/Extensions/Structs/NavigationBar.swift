
import SwiftUI

struct NavigationBar<Content: View>: View {
    
    @ViewBuilder let buttonContent: (() -> Content)
    let buttonAction: (() -> Void)?
    
    var body: some View {
        makeContent()
    }
    
    private func makeContent() -> some View {
        HStack {
            Rectangle()
                .fill(.clear)
                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32, height: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32)
            Spacer()
            Text("Heart Talk")
                .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32))
                .multilineTextAlignment(.center)
                .foregroundStyle(.darkWhite)
                .opacity(66)
            Spacer()
            if let buttonAction = buttonAction {
                Button {
                    HapticManager.shared.triggerHapticFeedback(.light)
                    buttonAction()
                } label: {
                    buttonContent()
                }
                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32, height: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32)
            }
        }
    }
    
}

