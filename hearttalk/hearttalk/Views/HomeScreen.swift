
import SwiftUI

struct HomeScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @State private var requestManager: RequestManager = RequestManager()
    
    @State private var isShowSettings: Bool = false
    @State private var isShowCreateCard: Bool = false
    @State private var isShowCreatePack: Bool = false
    @State private var isShowAgeAlert: Bool = false
    @State private var isShowDailyCard: Bool = false
    
    @State private var selectedCardPack: CardPack?
    @State private var selectedCardType: CardType?
    
    var body: some View {
        NavigationView {
            makeContent()
                .background(.lightBlack)
        }
        .sheet(isPresented: $isShowSettings) {
            AboutApp()
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $isShowCreateCard) {
            CreateScreen(createScreenType: .card)
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $isShowCreatePack) {
            CreateScreen(createScreenType: .pack)
                .environmentObject(viewModel)
        }
        .fullScreenCover(isPresented: $isShowDailyCard) {
            Questions(card: viewModel.dailyOriginalCard)
                .environmentObject(viewModel)
        }
        .alert(isPresented: $isShowAgeAlert) {
            Alert(title: Text(Localization.adultAlertTitle), message: Text(Localization.adultAlertMessage), primaryButton: .default(Text(Localization.confirm), action: {
                viewModel.isShowAgeAlert = false
            }), secondaryButton: .cancel(Text(Localization.cancel), action: {}))
        }
        .onOpenURL { url in
            if url.scheme == "hearttalk" {
                if url.host == "createScreen" {
                    isShowCreateCard.toggle()
                }
                if url.host == "dailyWidgetOpen" {
                    isShowDailyCard.toggle()
                }
            }
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
        ScrollView {
            LazyVStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24) {
                BannerAdView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                
                LazyVStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24) {
                    ForEach(viewModel.cardPacks) { cardPack in
                        Button(action: {
                            if cardPack.isAdult && viewModel.isShowAgeAlert {
                                isShowAgeAlert.toggle()
                            } else {
                                if cardPack.cardTypes.count != 0 {
                                    HapticManager.shared.triggerHapticFeedback(.light)
                                    SoundManager.shared.sound(.click1)
                                    selectedCardPack = cardPack
                                }
                            }
                        }) {
                            HomeCard(HomeCardProperties(color: Color(hex: cardPack.color),
                                                        header: cardPack.name,
                                                        text: cardPack.cardTypes.count == 0 ? Localization.empty : "\(cardPack.cardTypes.count) \(cardPack.cardTypes.count > 1 ? Localization.packs : Localization.pack)"))
                        }
                        .background {
                            NavigationLink(
                                destination: PacksScreen(cardPack: selectedCardPack)
                                    .environmentObject(viewModel)
                                    .navigationBarHidden(true),
                                isActive: Binding(
                                    get: { selectedCardPack == cardPack },
                                    set: { isActive in
                                        if !isActive { selectedCardPack = nil }
                                    }
                                )
                            ) {
                                EmptyView()
                            }
                        }
                    }
                }
                
                if let favoriteType = viewModel.favoriteType {
                    Button(action: {
                        HapticManager.shared.triggerHapticFeedback(.light)
                        SoundManager.shared.sound(.click1)
                        selectedCardType = favoriteType
                    }) {
                        HomeCard(HomeCardProperties(color: Color(hex: favoriteType.color),
                                                    header: favoriteType.name,
                                                    text: favoriteType.cards.count == 0 ? Localization.empty : "\(favoriteType.cards.count) \(favoriteType.cards.count ?? 0 > 1 ? Localization.cards : Localization.card)"))
                    }
                    .background {
                        NavigationLink(
                            destination: Questions(cardType: favoriteType)
                                .environmentObject(viewModel)
                                .navigationBarHidden(true),
                            isActive: Binding(
                                get: { selectedCardType == favoriteType },
                                set: { isActive in
                                    if !isActive { selectedCardType = nil }
                                }
                            )
                        ) {
                            EmptyView()
                        }
                    }
                }
                
                AddHomeCard() { type in
                    switch type {
                    case .pack:
                        isShowCreatePack.toggle()
                    case .card:
                        isShowCreateCard.toggle()
                    }
                }
            }
        }
        .scrollIndicators(.hidden, axes: .vertical)
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
    }
    
}

#Preview {
    HomeScreen()
}
