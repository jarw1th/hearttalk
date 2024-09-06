
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
            VStack(spacing: 24) {
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
                                    .frame(width: 16, height: 16)
                            }
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
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
            .padding(.top, 8)
            .padding(.bottom, 70)
            
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
                .font(.custom("PlayfairDisplay-Regular", size: 16))
                .underline()
                .multilineTextAlignment(.center)
                .foregroundStyle(.darkWhite)
                .opacity(66)
        }
    }
    
}

#Preview {
    WhatIsTheApp()
}
