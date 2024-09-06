
import SwiftUI

struct WhatIsCardView: View {
    
    @Binding var isSwipeBack: Bool
    @Binding var index: Int
    
    @State private var frontCardOffset: CGSize = .zero
    @State private var backCardOffset: CGSize = CGSize(width: 400, height: 0)
    @State private var backCardScale: CGFloat = 0.9
    @State private var frontCardRotation: Double = 0
    @State private var cardWidth: CGFloat = 0

    private let texts: [(String, String)] = [
        ("What is Heart talk?", "Heart Talk is the app designed to help families and couples strengthen their relationships through meaningful conversations. By providing a platform where users can engage with thoughtfully crafted questions, the app encourages deep and genuine communication."),
        ("A lot of content", "Users can select from a range of card decks, each containing a series of questions intended to prompt reflection and discussion. Whether it’s a family gathering or a quiet moment with a partner, these questions are designed to foster a deeper understanding and connection between individuals."),
        ("Get closer", "The core objective of Heart Talk is to bring people closer together by facilitating open and honest dialogue. By engaging with these prompts, users can explore each other's thoughts, feelings, and experiences, ultimately enhancing their relationships and building a stronger emotional bond."),
        ("AI", "The app also features an advanced AI that generates custom questions based on user prompts. This personalized approach allows users to explore topics that are particularly relevant to their own experiences and interests, further enhancing the quality of their conversations.")]
    
    var body: some View {
        ZStack {
            if texts.count > index + 1 {
                makeCardView(for: texts[index + 1])
                    .scaleEffect(backCardScale)
                    .offset(x: backCardOffset.width, y: backCardOffset.height)
                    .rotationEffect(.degrees(10))
                    .zIndex(0)
                
                makeCardView(for: texts[index])
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
            } else if texts.count == index + 1 {
                makeCardView(for: texts[index])
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
                    Text("You are perfect!")
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
        .onChange(of: isSwipeBack) { value in
            if value {
                swipeBack()
                isSwipeBack.toggle()
            }
        }
    }
    
    private func makeCardView(for card: (String, String)) -> some View {
        ZStack {
            VStack {
                Spacer()
                Text(card.1)
                    .font(.custom("PlayfairDisplay-SemiBold", size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.lightBlack)
                    .padding(.horizontal, 48)
                Spacer()
            }
            
            VStack {
                Text(card.0)
                    .font(.custom("PlayfairDisplay-Regular", size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.lightBlack)
                    .opacity(0.66)
                    .padding(.horizontal, 48)
                Spacer()
            }
            .padding(.top, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.darkWhite)
                .shadow(color: .shadow, radius: 5)
        )
    }
    
    private func moveToNextCard() {
        index = index + 1
    }
    
    private func resetCardPosition() {
        frontCardOffset = .zero
        frontCardRotation = 0
    }
    
    private func moveCardRightPosition() {
        frontCardOffset = CGSize(width: cardWidth / 1.6, height: -24)
        frontCardRotation = Double(10)
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
        
        index = index - 1
    }
    
}
