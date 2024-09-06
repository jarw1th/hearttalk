
import SwiftUI

struct CardView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    @State private var frontCardOffset: CGSize = .zero
    @State private var backCardOffset: CGSize = CGSize(width: 400, height: 0)
    @State private var backCardScale: CGFloat = 0.9
    @State private var frontCardRotation: Double = 0
    @State private var cardWidth: CGFloat = 0
    
    var body: some View {
        ZStack {
            if viewModel.cards.count > viewModel.cardIndex + 1 {
                makeCardView(for: viewModel.cards[viewModel.cardIndex + 1])
                    .scaleEffect(backCardScale)
                    .offset(x: backCardOffset.width, y: backCardOffset.height)
                    .rotationEffect(.degrees(10))
                    .zIndex(0)
                
                makeCardView(for: viewModel.cards[viewModel.cardIndex])
                    .offset(x: frontCardOffset.width, y: frontCardOffset.height)
                    .rotationEffect(.degrees(frontCardRotation))
                    .zIndex(1)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                frontCardOffset = gesture.translation
                                frontCardRotation = Double(gesture.translation.width / 20)
                                
                                if abs(frontCardOffset.width) < 50 {
                                    backCardOffset = CGSize(width: gesture.translation.width + (cardWidth / 2), height: backCardOffset.height)
                                }
                            }
                            .onEnded { gesture in
                                if frontCardOffset.width < -150 {
                                    withAnimation(.easeInOut) {
                                        frontCardOffset = CGSize(width: frontCardOffset.width > 0 ? 1000 : -1000, height: frontCardOffset.height)
                                        frontCardRotation = Double(frontCardOffset.width / 20)
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        moveCardRightPosition()
                                        moveToNextCard()
                                        withAnimation(.easeInOut) {
                                            backCardOffset = .zero
                                            resetCardPosition()
                                        }
                                        backCardOffset = CGSize(width: cardWidth / 1.6, height: -24)
                                    }
                                } else {
                                    withAnimation {
                                        resetCardPosition()
                                        backCardOffset = CGSize(width: cardWidth / 1.6, height: -24)
                                    }
                                }
                            }
                    )
                    .padding(.bottom, 48)
                    .padding(.horizontal, 20)
                    .background(
                        GeometryReader { reader in
                            Color.clear
                                .onAppear {
                                    backCardOffset = CGSize(width: reader.size.width / 1.6, height: -24)
                                    cardWidth = reader.size.width
                                }
                        }
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func makeCardView(for card: Card) -> some View {
        ZStack {
            VStack {
                Spacer()
                Text(card.question)
                    .font(.custom("PlayfairDisplay-SemiBold", size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.lightBlack)
                    .padding(.horizontal, 48)
                Spacer()
            }
            VStack {
                Spacer()
                HStack(spacing: 64) {
                    makeShareButton()
                    makeShareButton()
                    makeLikeButton()
                }
            }
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.darkWhite)
                .shadow(color: .shadow, radius: 5)
        )
    }
    
    private func makeLikeButton() -> some View {
        Button {
            
        } label: {
            Image("like")
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.darkGreen)
                .frame(width: 16, height: 16)
        }
    }
    
    private func makeShareButton() -> some View {
        Button {
            
        } label: {
            Image("shareCard")
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.darkGreen)
                .frame(width: 16, height: 16)
        }
    }
    
    private func moveToNextCard() {
        viewModel.cardIndex = viewModel.cardIndex + 1
    }
    
    private func resetCardPosition() {
        frontCardOffset = .zero
        frontCardRotation = 0
    }
    
    private func moveCardRightPosition() {
        frontCardOffset = CGSize(width: 1000, height: frontCardOffset.height)
        frontCardRotation = Double(10)
    }
    
}
