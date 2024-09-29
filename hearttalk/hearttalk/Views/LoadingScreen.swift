
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
    }
    
    private func makeContent() -> some View {
        VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 48) {
            makeLoader()
            makeText()
        }
        .fullScreenCover(isPresented: $isShowNext) {
            HomeScreen()
                .environmentObject(viewModel)
        }
        .onAppear {
            isShowNext.toggle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func makeLoader() -> some View {
        ZStack {
            Image("heartLogoPart")
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.darkWhite)
                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 200 : 400, height: UIDevice.current.userInterfaceIdiom == .phone ? 172 : 344)
            
            Image("hLogoPart")
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.lightBlack)
                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 54 : 106, height: UIDevice.current.userInterfaceIdiom == .phone ? 54 : 106)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    startRotation()
                }
        }
    }
    
    private func makeText() -> some View {
        Text("Heart Talk")
            .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 36 : 64))
            .multilineTextAlignment(.center)
            .foregroundStyle(.darkWhite)
            .opacity(66)
    }
    
    private func startRotation() {
        guard isLoading else { return }
        
        withAnimation(
            Animation.linear(duration: 1)
                .repeatForever(autoreverses: false)
        ) {
            rotation = 360
        }
    }
    
}

#Preview {
    LoadingScreen()
}
