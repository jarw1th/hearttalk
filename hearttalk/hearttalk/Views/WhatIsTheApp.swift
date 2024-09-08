
import SwiftUI

struct WhatIsTheApp: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var height: CGFloat = 0
    @State private var isSwipeBack: Bool = false
    @State private var index: Int = 0
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .edgesIgnoringSafeArea(.bottom)
    }
    
    private func makeContent() -> some View {
        VStack {
            makeCards()
        }
    }
    
    private func makeCards() -> some View {
        ZStack {
            VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32) {
                ZStack {
                    NavigationBar(buttonContent: {}, buttonAction: nil)
                    
                    HStack {
                        if index != 0 {
                            Button {
                                HapticManager.shared.triggerHapticFeedback(.soft)
                                isSwipeBack.toggle()
                            } label: {
                                Image("swipeBack")
                                    .renderingMode(.template)
                                    .resizable()
                                    .foregroundStyle(.darkWhite)
                                    .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32, height: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32)
                            }
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
                Spacer()
                    .background(
                        GeometryReader { reader in
                            Color.clear
                                .onAppear {
                                    height = reader.size.height
                                }
                        }
                    )
                makeBackButton()
            }
            .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 8 : 24)
            .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 70 : 120)
            
            WhatIsCardView(isSwipeBack: $isSwipeBack, index: $index)
                .frame(height: height)
        }
    }
    
    private func makeBackButton() -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text(Localization.goBack)
                .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32))
                .underline()
                .multilineTextAlignment(.center)
                .foregroundStyle(.darkWhite)
                .opacity(66)
        }
    }
    
}
