
import SwiftUI

struct PacksScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode
    let cardPack: CardPack?
    
    @State private var isShowSettings: Bool = false
    @State private var isShowAgeAlert: Bool = false
    
    @State private var selectedCardType: CardType?
    @State private var selectedNameCardType: CardType?
    @State private var selectedDescCardType: CardType?
    
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
        .sheet(item: $selectedNameCardType) { cardType in
            ChangeTextScreen(text: Binding(get: {
                cardType.name
            }, set: {
                let ct = CardType(id: cardType.id, name: $0, text: cardType.text)
                viewModel.updateType(ct)
            }))
        }
        .sheet(item: $selectedDescCardType) { cardType in
            ChangeTextScreen(text: Binding(get: {
                cardType.text
            }, set: {
                let ct = CardType(id: cardType.id, name: cardType.name, text: $0)
                viewModel.updateType(ct)
            }))
        }
        .alert(isPresented: $isShowAgeAlert) {
            Alert(title: Text(Localization.adultAlertTitle), message: Text(Localization.adultAlertMessage), primaryButton: .default(Text(Localization.confirm), action: {
                UserDefaultsManager.shared.isShowAgeAlert = false
            }), secondaryButton: .cancel(Text(Localization.cancel), action: {}))
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
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24) {
                    ForEach(viewModel.cardTypes) { cardType in
                        Button(action: {
                            if cardType.isAdult && UserDefaultsManager.shared.isShowAgeAlert {
                                isShowAgeAlert.toggle()
                            } else {
                                HapticManager.shared.triggerHapticFeedback(.light)
                                SoundManager.shared.sound(.click1)
                                selectedCardType = cardType
                            }
                        }) {
                            HomePack(HomeCardProperties(color: Color(hex: cardType.color),
                                                        header: cardType.name,
                                                        text: cardType.cards.count == 0 ? Localization.empty : "\(cardType.cards.count) \(cardType.cards.count > 1 ? Localization.cards : Localization.card)",
                                                        description: cardType.text))
                        }
                        .contextMenu {
                            if cardType.isCustom {
                                Button {
                                    HapticManager.shared.triggerHapticFeedback(.light)
                                    SoundManager.shared.sound(.click1)
                                    viewModel.deleteType(cardType: cardType)
                                } label: {
                                    Text("Delete")
                                }
                                Button {
                                    HapticManager.shared.triggerHapticFeedback(.light)
                                    SoundManager.shared.sound(.click1)
                                    selectedNameCardType = cardType
                                } label: {
                                    Text("Change name")
                                }
                                Button {
                                    HapticManager.shared.triggerHapticFeedback(.light)
                                    SoundManager.shared.sound(.click1)
                                    selectedDescCardType = cardType
                                } label: {
                                    Text("Change description")
                                }
                            }
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
