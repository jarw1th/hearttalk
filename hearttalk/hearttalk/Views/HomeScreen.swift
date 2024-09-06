
import SwiftUI

struct HomeScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    @State private var isShowSettings: Bool = false
    @State private var isShowCreateCard: Bool = false
    @State private var isShowCreatePack: Bool = false
    @State private var isShowGenerate: Bool = false
    
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
        .sheet(isPresented: $isShowGenerate) {
            GenerateScreen()
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
                    .frame(width: 16, height: 16)
            } buttonAction: {
                isShowSettings.toggle()
            }
            .padding(.horizontal, 20)
            
            makeFeed()
        }
        .padding(.top, 8)
    }
    
    private func makeFeed() -> some View {
        ScrollView {
            LazyVStack {
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
            .padding(.horizontal, 20)
            LazyVStack {
                AddHomeCard() { type in
                    switch type {
                    case .pack:
                        isShowCreatePack.toggle()
                    case .card:
                        isShowCreateCard.toggle()
                    }
                }
                GenerateHomeCard() {
                    isShowGenerate.toggle()
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
}

#Preview {
    HomeScreen()
}
