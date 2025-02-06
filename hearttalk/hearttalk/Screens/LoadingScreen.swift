
import SwiftUI

struct LoadingScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @StateObject private var onlineViewModel: OnlineViewModel = OnlineViewModel()
    
    @State private var isLoading: Bool = true
    @State private var isShowNext: Bool = false
    @State private var isShowOnboarding: Bool = false
    @State private var rotation: Double = 0
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .ignoresSafeArea()
            .preferredColorScheme(UserDefaultsManager.shared.isDarkMode ? .dark : .light)
            .onChange(of: viewModel.htPacks) { value in
                if !value.isEmpty && UserDefaultsManager.shared.isOnboarded {
                    isShowNext = true
                }
            }
            .onAppear {
                if !UserDefaultsManager.shared.isOnboarded {
                    isShowOnboarding.toggle()
                } else {
                    if !viewModel.htPacks.isEmpty {
                        isShowNext = true
                    }
                }
            }
    }
    
    private func makeContent() -> some View {
        VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 48) {
            LoadingView()
            makeText()
        }
        .fullScreenCover(isPresented: $isShowNext) {
            TabScreen()
                .environmentObject(viewModel)
                .environmentObject(onlineViewModel)
        }
        .fullScreenCover(isPresented: $isShowOnboarding) {
            if !viewModel.htPacks.isEmpty {
                isShowNext = true
            }
        } content: {
            WhatIsTheApp()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func makeText() -> some View {
        Text("Heart Talk")
            .font(.custom("Poppins-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 36 : 64))
            .multilineTextAlignment(.center)
            .foregroundStyle(.darkWhite)
            .opacity(66)
    }
    
}
