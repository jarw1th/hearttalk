
import SwiftUI

struct HomeScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    @State private var isShowSettings: Bool = false
    @State private var isShowCreateCard: Bool = false
    @State private var isShowCreatePack: Bool = false
    
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
                LazyVStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24) {
                    ForEach(viewModel.cardTypes) { cardType in
                        Button(action: {
                            HapticManager.shared.triggerHapticFeedback(.light)
                            selectedCardType = cardType
                        }) {
                            HomeCard(HomeCardProperties(color: Color(hex: cardType.color),
                                                        header: cardType.name,
                                                        text: cardType.cards.count == 0 ? Localization.empty : "\(cardType.cards.count) \(cardType.cards.count > 1 ? Localization.cards : Localization.card)",
                                                        isAvailable: true))
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
                
                LazyVStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24) {
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
        }
        .applyScrollIndicators(false, axes: .vertical)
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
    }
    
}

