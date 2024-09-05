
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
    }
    
    private func makeContent() -> some View {
        VStack(spacing: 16) {
            makeLoader()
            makeText()
        }
        .fullScreenCover(isPresented: $isShowNext) {
            HomeScreen()
                .environmentObject(viewModel)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func makeLoader() -> some View {
        ZStack {
            Image("heartLogoPart")
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.darkWhite)
                .frame(width: 200, height: 172)
            
            Image("hLogoPart")
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.lightBlack)
                .frame(width: 54, height: 54)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    startRotation()
                }
        }
    }
    
    private func makeText() -> some View {
        Text("Heart Talk")
            .font(.custom("PlayfairDisplay-Regular", size: 36))
            .multilineTextAlignment(.center)
            .foregroundStyle(.darkWhite)
            .opacity(66)
    }
    
    private func checkData() {
        isShowNext.toggle()
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
