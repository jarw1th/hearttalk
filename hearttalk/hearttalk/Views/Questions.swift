
import SwiftUI

struct Questions: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode
    let cardType: CardType?
    let card: Card?
    
    @State private var questionMode: QuestionMode = .cards
    
    @State private var isSwipeBack: Bool = false
    @State private var isShowCreateNote: Bool = false
    @State private var isShowNotes: Bool = false
    
    init(cardType: CardType? = nil, card: Card? = nil) {
        self.cardType = cardType
        self.card = card
    }
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .edgesIgnoringSafeArea(.bottom)
            .onAppear {
                if let card = card {
                    let cardType = card.parentCardType.first
                    viewModel.fetchCards(forCardTypeId: cardType?.id ?? "")
                    viewModel.cardIndex = viewModel.cards.firstIndex(of: card) ?? 0
                } else {
                    viewModel.fetchCards(forCardTypeId: cardType?.id ?? "")
                    viewModel.cardIndex = 0
                }
            }
            .onTapGesture {
                UserDefaultsManager.shared.isShowTip = false
            }
            .sheet(isPresented: $isShowCreateNote) {
                CreateNote()
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $isShowNotes) {
                Notes(card: viewModel.cards[viewModel.cardIndex])
                    .environmentObject(viewModel)
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
            VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32) {
                ZStack {
                    NavigationBar {
                        Image(questionMode.imageName())
                            .renderingMode(.template)
                            .resizable()
                            .foregroundStyle(.darkWhite)
                            .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32, height: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32)
                    } buttonAction: {
                        questionMode.toggle()
                    }
                    
                    HStack {
                        if viewModel.cardIndex != 0 {
                            Button {
                                HapticManager.shared.triggerHapticFeedback(.soft)
                                SoundManager.shared.sound(.card)
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
                ZStack(alignment: .bottom) {
                    CardView(isSwipeBack: $isSwipeBack, isShowCreateNote: $isShowCreateNote, isShowNotes: $isShowNotes)
                        .environmentObject(viewModel)
                    makeBackButton()
                }
            }
            .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 8 : 24)
            .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 70 : 120)
        }
    }
    
    private func makeList() -> some View {
        VStack {
            if viewModel.cards.count == 0 {
                ZStack {
                    VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32) {
                        NavigationBar {
                            Image(questionMode.imageName())
                                .renderingMode(.template)
                                .resizable()
                                .foregroundStyle(.darkWhite)
                                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32, height: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32)
                        } buttonAction: {
                            questionMode.toggle()
                        }
                        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
                        Spacer()
                        makeBackButton()
                    }
                    .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 8 : 24)
                    .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 70 : 120)
                    
                    VStack {
                        Spacer()
                        Text(Localization.thatIsAll)
                            .font(.custom("PlayfairDisplay-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 32))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.darkWhite)
                            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 48 : 100)
                        Spacer()
                    }
                }
            } else {
                VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32) {
                    NavigationBar {
                        Image(questionMode.imageName())
                            .renderingMode(.template)
                            .resizable()
                            .foregroundStyle(.darkWhite)
                            .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32, height: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32)
                    } buttonAction: {
                        questionMode.toggle()
                    }
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack {
                            ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, card in
                                ListItem(number: index + 1, question: card.question) {
                                    viewModel.cardIndex = index
                                    questionMode.toggle()
                                }
                            }
                        }
                        
                    }
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20)
                    )
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
                
                    makeBackButton()
                }
                .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 8 : 24)
                .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 70 : 120)
            }
        }
    }
    
    private func makeBackButton() -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
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
