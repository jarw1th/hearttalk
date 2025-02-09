//
//  OnlineCardView.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 01.02.2025.
//

import SwiftUI

struct OnlineCardView: View {
    
    @EnvironmentObject var viewModel: OnlineViewModel
    
    @Binding var isSaveCurrent: Bool
    
    @State private var frontCardOffset: CGSize = .zero
    @State private var backCardOffset: CGSize = CGSize(width: 400, height: 0)
    @State private var backCardScale: CGFloat = 0.9
    @State private var frontCardRotation: Double = 0
    @State private var cardWidth: CGFloat = 0
    
    @State private var isShare: Bool = false
    @State private var isFlipped: Bool = false
    @State private var shareImage: Data?
    
    var body: some View {
        ZStack {
            if viewModel.cards.count > viewModel.cardIndex + 1 {
                makeBackCardView(for: viewModel.cards[viewModel.cardIndex + 1])
                    .scaleEffect(backCardScale)
                    .offset(x: backCardOffset.width, y: backCardOffset.height)
                    .rotationEffect(.degrees(10))
                    .zIndex(0)
                
                makeCardView(for: viewModel.cards[viewModel.cardIndex])
                    .offset(x: frontCardOffset.width, y: frontCardOffset.height)
                    .rotationEffect(.degrees(frontCardRotation))
                    .zIndex(1)
                    .simultaneousGesture(
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
                                    SoundManager.shared.sound(.card)
                                    
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
                                            backCardOffset = CGSize(width: cardWidth / 1.6, height: UIDevice.current.userInterfaceIdiom == .phone ? -24 : -36)
                                        }
                                    }
                                } else {
                                    withAnimation {
                                        resetCardPosition()
                                        backCardOffset = CGSize(width: cardWidth / 1.6, height: UIDevice.current.userInterfaceIdiom == .phone ? -24 : -36)
                                    }
                                }
                            }
                    )
                    .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 48 : 72)
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 180)
                    .background(
                        GeometryReader { reader in
                            Color.clear
                                .onAppear {
                                    backCardOffset = CGSize(width: reader.size.width / 1.6, height: UIDevice.current.userInterfaceIdiom == .phone ? -24 : -36)
                                    cardWidth = reader.size.width
                                }
                        }
                    )
            } else if viewModel.cards.count == viewModel.cardIndex + 1 {
                makeCardView(for: viewModel.cards[viewModel.cardIndex])
                    .offset(x: frontCardOffset.width, y: frontCardOffset.height)
                    .rotationEffect(.degrees(frontCardRotation))
                    .zIndex(1)
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { gesture in
                                frontCardOffset = gesture.translation
                                frontCardRotation = Double(gesture.translation.width / 20)
                            }
                            .onEnded { gesture in
                                if frontCardOffset.width < -150 {
                                    HapticManager.shared.triggerHapticFeedback(.soft)
                                    SoundManager.shared.sound(.card)
                                    
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
                    .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 48 : 72)
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 180)
                    .background(
                        GeometryReader { reader in
                            Color.clear
                                .onAppear {
                                    backCardOffset = CGSize(width: reader.size.width / 1.6, height: UIDevice.current.userInterfaceIdiom == .phone ? -24 : -36)
                                    cardWidth = reader.size.width
                                }
                        }
                    )
            } else {
                VStack {
                    Spacer()
                    Text(Localization.emptyPack)
                        .font(.custom("Poppins-SemiBold", size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.darkWhite)
                        .padding(.horizontal, 48)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(item: $shareImage) { imageData in
            var activityItems: [Any] = [imageData]
            if viewModel.cards.count > viewModel.cardIndex {
                activityItems.append(viewModel.cards[viewModel.cardIndex].question)
            }
            return ActivityViewControllerRepresentableCenter(activityItems: activityItems)
        }
    }
    
    @ViewBuilder
    private func makeCardView(for card: Card) -> some View {
        if isFlipped {
            backCardView(card)
        } else {
            frontCardView(card)
        }
    }
    
    private func frontCardView(_ card: Card) -> some View {
        ZStack {
            VStack {
                HStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24) {
                    if viewModel.cardIndex != 0 {
                        makeSwipeBackButton(card)
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32)
            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32)
            VStack {
                Spacer()
                Text(card.question)
                    .font(.custom("Poppins-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 32))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.lightBlack)
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 48 : 64)
                Spacer()
            }
            VStack {
                Spacer()
                HStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 64 : 80) {
                    makeSpeakButton(card)
                    makeShareButton(card)
                    makeDownloadButton(card)
                }
            }
            .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.darkWhite)
                .shadow(color: .shadow, radius: 5)
                .simultaneousGesture(
                    TapGesture()
                        .onEnded {
                            if card.isFlipCard {
                                HapticManager.shared.triggerHapticFeedback(.light)
                                SoundManager.shared.sound(.card)
                                
                                isFlipped = true
                            }
                        }
                )
        )
    }
    
    private func backCardView(_ card: Card) -> some View {
        ZStack {
            VStack {
                Text(Localization.answerCard)
                    .font(.custom("Poppins-Regular", size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.lightBlack)
                Spacer()
            }
            .padding(.top, 20)
            VStack {
                Spacer()
                Text(card.answer)
                    .font(.custom("Poppins-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 32))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.lightBlack)
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 48 : 64)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .shadow, radius: 5)
        )
        .simultaneousGesture(
            TapGesture()
                .onEnded {
                    HapticManager.shared.triggerHapticFeedback(.light)
                    SoundManager.shared.sound(.card)
                    
                    isFlipped = false
                }
        )
    }
    
    private func makeBackCardView(for card: Card) -> some View {
        ZStack {
            VStack {
                Spacer()
                Text(card.question)
                    .font(.custom("Poppins-SemiBold", size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.lightBlack)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 24)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.darkWhite)
                .shadow(color: .shadow, radius: 5)
        )
        .simultaneousGesture(
            TapGesture()
                .onEnded {
                    HapticManager.shared.triggerHapticFeedback(.light)
                    SoundManager.shared.sound(.card)
                    
                    withAnimation(.easeInOut) {
                        frontCardOffset = CGSize(width: frontCardOffset.width - 50, height: frontCardOffset.height)
                        frontCardRotation = Double(50 / 20)
                    
                        backCardOffset = CGSize(width: 50 + (cardWidth / 2), height: backCardOffset.height)
                    }
                    
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
                            backCardOffset = CGSize(width: cardWidth / 1.6, height: UIDevice.current.userInterfaceIdiom == .phone ? -24 : -36)
                        }
                    }
                }
        )
    }
    
    private func makeDownloadButton(_ card: Card) -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            isSaveCurrent = true
        } label: {
            Image("download")
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.lightBlack)
                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32, height: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32)
        }
    }
    
    private func makeShareButton(_ card: Card) -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            shareAction(card)
        } label: {
            Image("shareCard")
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.lightBlack)
                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32, height: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32)
        }
    }
    
    private func makeSpeakButton(_ card: Card) -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            speakAction(card)
        } label: {
            Image("speaker")
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.lightBlack)
                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32, height: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32)
        }
    }
    
    private func makeSwipeBackButton(_ card: Card) -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            swipeBack()
        } label: {
            Icon(name: "swipeBack", size: .custom(16), color: .lightBlack)
        }
    }
    
    private func moveToNextCard() {
        viewModel.cardIndex = viewModel.cardIndex + 1
        isFlipped = false
        if viewModel.cardIndex < viewModel.cards.count && UserDefaultsManager.shared.isReadCard  {
            SpeechManager.shared.speak(text: viewModel.cards[viewModel.cardIndex].question)
        }
    }
    
    private func resetCardPosition() {
        frontCardOffset = .zero
        frontCardRotation = 0
    }
    
    private func moveCardRightPosition() {
        frontCardOffset = CGSize(width: cardWidth / 1.6, height: UIDevice.current.userInterfaceIdiom == .phone ? -24 : -36)
        frontCardRotation = Double(10)
    }
    
    private func shareAction(_ card: Card) {
        let image = createCardImage(card.question)
        shareImage = image?.jpegData(compressionQuality: 1.0)
    }
    
    private func speakAction(_ card: Card) {
        SpeechManager.shared.speak(text: card.question, shouldStartNew: false)
    }
    
    private func swipeBack() {
        withAnimation(.easeInOut) {
            frontCardOffset = CGSize(width: cardWidth / 1.6, height: UIDevice.current.userInterfaceIdiom == .phone ? -24 : -36)
            frontCardRotation = Double(10)
            backCardOffset = CGSize(width: cardWidth / 1.5, height: UIDevice.current.userInterfaceIdiom == .phone ? -24 : -36)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            frontCardOffset = CGSize(width: -1000, height: 0)
            frontCardRotation = Double(-10)
            backCardOffset = CGSize(width: cardWidth / 1.6, height: UIDevice.current.userInterfaceIdiom == .phone ? -24 : -36)
            withAnimation(.easeInOut) {
                frontCardOffset = .zero
                frontCardRotation = 0
            }
        }
        
        viewModel.cardIndex = viewModel.cardIndex - 1
        isFlipped = false
    }
    
}
