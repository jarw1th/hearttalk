
import SwiftUI

struct WhatIsTheApp: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var index: Int = 0
    @State private var isLast: Bool = false
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .edgesIgnoringSafeArea(.bottom)
            .onChange(of: isLast) { value in
                guard value else { return }
                UserDefaultsManager.shared.isOnboarded = true
                dismiss()
            }
    }
    
    private func makeContent() -> some View {
        VStack {
            makeCards()
        }
    }
    
    private func makeCards() -> some View {
        ZStack {
            WhatIsCardView(index: $index, isLastCard: $isLast)
                .frame(maxHeight: .infinity)
                .padding(.vertical, 40)
        }
    }
    
}

