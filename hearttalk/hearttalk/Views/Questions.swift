
import SwiftUI

struct Questions: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode
    let cardType: CardType
    
    @State private var questionMode: QuestionMode = .cards
    @State private var height: CGFloat = 0
    
    @State private var isSwipeBack: Bool = false
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .edgesIgnoringSafeArea(.bottom)
            .onAppear {
                viewModel.fetchCards(forCardTypeId: cardType.id)
                viewModel.cardIndex = 0
            }
    }
    
    private func makeContent() -> some View {
        VStack {
            if questionMode == .list {
                makeList()
            } else {
                makeCards()
            }
        }
    }
    
    private func makeCards() -> some View {
        ZStack {
            VStack(spacing: 24) {
                ZStack {
                    NavigationBar {
                        Image(questionMode.imageName())
                            .renderingMode(.template)
                            .resizable()
                            .foregroundStyle(.darkWhite)
                            .frame(width: 16, height: 16)
                    } buttonAction: {
                        questionMode.toggle()
                    }
                    
                    HStack {
                        if viewModel.cardIndex != 0 {
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
            
            CardView(isSwipeBack: $isSwipeBack)
                .environmentObject(viewModel)
                .frame(height: height)
        }
    }
    
    private func makeList() -> some View {
        VStack {
            if viewModel.cards.count == 0 {
                ZStack {
                    VStack(spacing: 24) {
                        NavigationBar {
                            Image(questionMode.imageName())
                                .renderingMode(.template)
                                .resizable()
                                .foregroundStyle(.darkWhite)
                                .frame(width: 16, height: 16)
                        } buttonAction: {
                            questionMode.toggle()
                        }
                        .padding(.horizontal, 20)
                        Spacer()
                        makeBackButton()
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 70)
                    
                    VStack {
                        Spacer()
                        Text("That’s all")
                            .font(.custom("PlayfairDisplay-SemiBold", size: 20))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.darkWhite)
                            .padding(.horizontal, 48)
                        Spacer()
                    }
                }
            } else {
                VStack(spacing: 24) {
                    NavigationBar {
                        Image(questionMode.imageName())
                            .renderingMode(.template)
                            .resizable()
                            .foregroundStyle(.darkWhite)
                            .frame(width: 16, height: 16)
                    } buttonAction: {
                        questionMode.toggle()
                    }
                    .padding(.horizontal, 20)
                    
                    ScrollView {
                        LazyVStack {
                            ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, card in
                                ListItem(number: index + 1, question: card.question) {
                                    viewModel.cardIndex = index
                                    questionMode.toggle()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    makeBackButton()
                }
                .padding(.top, 8)
                .padding(.bottom, 70)
            }
        }
    }
    
    private func makeBackButton() -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text("Go back")
                .font(.custom("PlayfairDisplay-Regular", size: 16))
                .underline()
                .multilineTextAlignment(.center)
                .foregroundStyle(.darkWhite)
                .opacity(66)
        }
    }
    
}

#Preview {
    Questions(cardType: CardType(id: "", name: ""))
}
