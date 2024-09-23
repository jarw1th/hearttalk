
import SwiftUI

struct PacksScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode
    let cardPack: CardPack?
    
    @State private var isShowSettings: Bool = false
    
    @State private var selectedCardType: CardType?
    
    var body: some View {
        NavigationView {
            makeContent()
                .background(.lightBlack)
                .edgesIgnoringSafeArea(.bottom)
        }
        .onAppear {
            viewModel.fetchAllCardTypes(forCardPackId: cardPack?.id ?? "")
            viewModel.cardIndex = 0
        }
        .sheet(isPresented: $isShowSettings) {
            AboutApp()
                .environmentObject(viewModel)
        }
    }
    
    private func makeContent() -> some View {
        VStack(spacing: 24) {
            NavigationBar {
                Image("settings")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundStyle(.darkWhite)
                    .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32, height: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32)
            } buttonAction: {
                isShowSettings.toggle()
            }
            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
            
            makeFeed()
        }
        .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 8 : 24)
    }
    
    private func makeFeed() -> some View {
        VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32) {
            ScrollView {
                LazyVStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24) {
                    ForEach(viewModel.cardTypes) { cardType in
                        Button(action: {
                            HapticManager.shared.triggerHapticFeedback(.light)
                            SoundManager.shared.sound(.click1)
                            selectedCardType = cardType
                        }) {
                            HomePack(HomeCardProperties(color: Color(hex: cardType.color),
                                                        header: cardType.name,
                                                        text: cardType.cards.count == 0 ? Localization.empty : "\(cardType.cards.count) \(cardType.cards.count > 1 ? Localization.cards : Localization.card)",
                                                        description: cardType.text))
                        }
                        .background(
                            NavigationLink(
                                destination: Questions(cardType: selectedCardType ?? cardType)
                                    .environmentObject(viewModel)
                                    .navigationBarHidden(true),
                                isActive: Binding(
                                    get: { selectedCardType == cardType },
                                    set: { isActive in
                                        if !isActive { selectedCardType = nil }
                                    }
                                )
                            ) {
                                EmptyView()
                            }
                        )
                    }
                }
            }
            .scrollIndicators(.hidden, axes: .vertical)
            .clipShape(
                RoundedRectangle(cornerRadius: 20)
            )
            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
        
            makeBackButton()
        }
        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 70 : 120)
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

#Preview {
    HomeScreen()
}
