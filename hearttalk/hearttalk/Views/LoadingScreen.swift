
import SwiftUI

struct LoadingScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    @State private var isLoading: Bool = true
    @State private var isShowNext: Bool = false
    @State private var rotation: Double = 0
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .ignoresSafeArea()
            .preferredColorScheme(UserDefaultsManager.shared.isDarkMode ? .dark : .light)
            .onChange(of: viewModel.cardPacks) { value in
                if !value.isEmpty {
                    isShowNext.toggle()
                }
            }
            .onAppear {
                if !viewModel.cardPacks.isEmpty {
                    isShowNext.toggle()
                }
            }
    }
    
    private func makeContent() -> some View {
        VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 48) {
            LoadingView()
            makeText()
        }
        .fullScreenCover(isPresented: $isShowNext) {
            HomeScreen()
                .environmentObject(viewModel)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func makeText() -> some View {
        Text("Heart Talk")
            .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 36 : 64))
            .multilineTextAlignment(.center)
            .foregroundStyle(.darkWhite)
            .opacity(66)
    }
    
}
