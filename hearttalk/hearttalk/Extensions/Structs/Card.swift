
import SwiftUI

struct CardView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    @Binding var isSwipeBack: Bool
    
    @State private var frontCardOffset: CGSize = .zero
    @State private var backCardOffset: CGSize = CGSize(width: 400, height: 0)
    @State private var backCardScale: CGFloat = 0.9
    @State private var frontCardRotation: Double = 0
    @State private var cardWidth: CGFloat = 0
    
    @State private var isShare: Bool = false
    @State private var shareImage: UIImage?
    
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
                                    HapticManager.shared.triggerHapticFeedback(.soft)
                                    
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
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            backCardOffset = CGSize(width: cardWidth / 1.6, height: -24)
                                        }
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
            } else if viewModel.cards.count == viewModel.cardIndex + 1 {
                makeCardView(for: viewModel.cards[viewModel.cardIndex])
                    .offset(x: frontCardOffset.width, y: frontCardOffset.height)
                    .rotationEffect(.degrees(frontCardRotation))
                    .zIndex(1)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                frontCardOffset = gesture.translation
                                frontCardRotation = Double(gesture.translation.width / 20)
                            }
                            .onEnded { gesture in
                                if frontCardOffset.width < -150 {
                                    HapticManager.shared.triggerHapticFeedback(.soft)
                                    
                                    withAnimation(.easeInOut) {
                                        frontCardOffset = CGSize(width: frontCardOffset.width > 0 ? 1000 : -1000, height: frontCardOffset.height)
                                        frontCardRotation = Double(frontCardOffset.width / 20)
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        moveToNextCard()
                                        withAnimation(.easeInOut) {
                                            resetCardPosition()
                                        }
                                    }
                                } else {
                                    withAnimation {
                                        resetCardPosition()
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
            } else {
                VStack {
                    Spacer()
                    Text("That’s all")
                        .font(.custom("PlayfairDisplay-SemiBold", size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.darkWhite)
                        .padding(.horizontal, 48)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $isShare) {
            ActivityViewControllerRepresentableCenter(activityItems: [shareImage])
        }
        .onChange(of: isSwipeBack) { value in
            if value {
                swipeBack()
                isSwipeBack.toggle()
            }
        }
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
                    makeSpeakButton(card)
                    makeShareButton(card)
                    makeLikeButton(card)
                }
            }
            .padding(.bottom, 24)
            
            if card == viewModel.cards[viewModel.cardIndex] && viewModel.isShowTip {
                VStack {
                    Spacer()
                    ZStack {
                        Image("tipBackground")
                            .renderingMode(.template)
                            .resizable()
                            .foregroundStyle(.lightBlack)
                            .frame(width: 160, height: 40)
                        
                        Text("Hold for your custom packs")
                            .font(.custom("PlayfairDisplay-Regular", size: 10))
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.darkWhite)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 10)
                    }
                }
                .padding(.bottom, 48)
                .padding(.leading, 48)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.darkWhite)
                .shadow(color: .shadow, radius: 5)
        )
    }
    
    private func makeLikeButton(_ card: Card) -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            likeAction(card)
        } label: {
            Image(viewModel.isCardFavorite ? "liked" : "like")
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.darkGreen)
                .frame(width: 16, height: 16)
        }
    }
    
    private func makeShareButton(_ card: Card) -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            shareAction(card)
        } label: {
            Image("shareCard")
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.darkGreen)
                .frame(width: 16, height: 16)
        }
    }
    
    private func makeSpeakButton(_ card: Card) -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            speakAction(card)
        } label: {
            Image("speaker")
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
        frontCardOffset = CGSize(width: cardWidth / 1.6, height: -24)
        frontCardRotation = Double(10)
    }
    
    private func shareAction(_ card: Card) {
        shareImage = viewModel.createCardImage(card.question)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isShare.toggle()
        }
    }
    
    private func speakAction(_ card: Card) {
        viewModel.speak(text: card.question)
    }
    
    private func likeAction(_ card: Card) {
        viewModel.addCardToFavorites(card)
    }
    
    private func swipeBack() {
        withAnimation(.easeInOut) {
            frontCardOffset = CGSize(width: cardWidth / 1.6, height: -24)
            frontCardRotation = Double(10)
            backCardOffset = CGSize(width: cardWidth / 1.5, height: -24)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            frontCardOffset = CGSize(width: -1000, height: 0)
            frontCardRotation = Double(-10)
            backCardOffset = CGSize(width: cardWidth / 1.6, height: -24)
            withAnimation(.easeInOut) {
                frontCardOffset = .zero
                frontCardRotation = 0
            }
        }
        
        viewModel.cardIndex = viewModel.cardIndex - 1
    }
    
}
