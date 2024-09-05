
import SwiftUI

struct HomeScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    @State private var isShowSettings: Bool = false
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
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
                HomeCard(HomeCardProperties(color: Color("DefaultColor"),
                                            header: "Default mode",
                                            text: "52 cards",
                                            isAvailable: true,
                                            tapAction: {}))
                AddHomeCard() {}
            }
            .padding(.horizontal, 20)
        }
    }
    
}

#Preview {
    HomeScreen()
}
