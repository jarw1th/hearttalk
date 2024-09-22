
import SwiftUI

struct NoteCardView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    @Binding var isSwipeBack: Bool
    
    @State private var frontCardOffset: CGSize = .zero
    @State private var backCardOffset: CGSize = CGSize(width: 400, height: 0)
    @State private var backCardScale: CGFloat = 0.9
    @State private var frontCardRotation: Double = 0
    @State private var cardWidth: CGFloat = 0
    
    var body: some View {
        ZStack {
            if viewModel.notes.count > viewModel.noteIndex + 1 {
                makeBackCardView(for: viewModel.notes[viewModel.noteIndex + 1])
                    .scaleEffect(backCardScale)
                    .offset(x: backCardOffset.width, y: backCardOffset.height)
                    .rotationEffect(.degrees(10))
                    .zIndex(0)
                
                makeCardView(for: viewModel.notes[viewModel.noteIndex])
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
            } else if viewModel.notes.count == viewModel.noteIndex + 1 {
                makeCardView(for: viewModel.notes[viewModel.noteIndex])
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
                    Text(Localization.thatIsAll)
                        .font(.custom("PlayfairDisplay-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 32))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.darkWhite)
                        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 48 : 100)
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
    
    private func makeCardView(for note: Note) -> some View {
        ZStack {
            VStack {
                Spacer()
                Text(note.text)
                    .font(.custom("PlayfairDisplay-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 32))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.lightBlack)
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 48 : 64)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.darkWhite)
                .shadow(color: .shadow, radius: 5)
        )
    }
    
    private func makeBackCardView(for note: Note) -> some View {
        ZStack {
            VStack {
                Spacer()
                Text(note.text)
                    .font(.custom("PlayfairDisplay-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 32))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.lightBlack)
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 48 : 64)
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
    
    private func moveToNextCard() {
        viewModel.noteIndex = viewModel.noteIndex + 1
    }
    
    private func resetCardPosition() {
        frontCardOffset = .zero
        frontCardRotation = 0
    }
    
    private func moveCardRightPosition() {
        frontCardOffset = CGSize(width: cardWidth / 1.6, height: UIDevice.current.userInterfaceIdiom == .phone ? -24 : -36)
        frontCardRotation = Double(10)
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
        
        viewModel.noteIndex = viewModel.noteIndex - 1
    }
    
}
