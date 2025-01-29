
import SwiftUI

struct WhatIsTheApp: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var height: CGFloat = 0
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
                SingleBackTopBar(text: "What is Heart Talk?") {
                    dismiss()
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
            }
            .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 8 : 24)
            .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 70 : 120)
            
            WhatIsCardView(index: $index)
                .frame(height: height)
        }
    }
    
}

