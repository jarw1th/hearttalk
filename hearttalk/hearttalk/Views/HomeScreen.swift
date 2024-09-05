
import SwiftUI

struct HomeScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    @State private var isShowSettings: Bool = false
    @State private var isShowCreateCard: Bool = false
    @State private var isShowCreatePack: Bool = false
    
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
                    NavigationLink(destination: {
                        Questions(cardType: cardType)
                            .environmentObject(viewModel)
                            .navigationBarHidden(true)
                    }, label: {
                        HomeCard(HomeCardProperties(color: Color(hex: cardType.color),
                                                    header: cardType.name,
                                                    text: "\(cardType.cards.count) cards",
                                                    isAvailable: true))
                    })
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
            }
            .padding(.horizontal, 20)
        }
    }
    
}

#Preview {
    HomeScreen()
}
