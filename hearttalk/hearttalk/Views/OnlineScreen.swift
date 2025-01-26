
import SwiftUI

struct OnlineScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var onlineViewModel: OnlineViewModel = OnlineViewModel()
    
    @State private var needsToSign: Bool = true
    @State private var isShowProfile: Bool = false
    @State private var isShowSignScreen: Bool = false
    @State private var selectedType: OnlineSearchType = .cards
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationView {
            makeContent()
                .background(.lightBlack)
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }
                .edgesIgnoringSafeArea(.bottom)
        }
        .onAppear {
            if onlineViewModel.isSignedIn {
                onlineViewModel.fetchQuestions()
            } else if needsToSign {
                isShowSignScreen.toggle()
            } else {
                dismiss()
            }
        }
        .onChange(of: selectedType) { newValue in
            switch newValue {
            case .cards:
                if onlineViewModel.questions.isEmpty {
                    onlineViewModel.fetchQuestions()
                }
            case .accounts:
                if onlineViewModel.users.isEmpty {
                    onlineViewModel.fetchUsers()
                }
            case .packs:
                if onlineViewModel.packs.isEmpty {
                    onlineViewModel.fetchPacks()
                }
            }
        }
        .onChange(of: needsToSign) { newValue in
            if newValue {
                dismiss()
            }
        }
        .onChange(of: onlineViewModel.isSignedIn) { newValue in
            if !newValue {
                isShowSignScreen.toggle()
            }
        }
        .sheet(isPresented: $isShowSignScreen) {
            SignScreen(needsToSign: $needsToSign)
                .environmentObject(onlineViewModel)
        }
        .sheet(isPresented: $isShowProfile) {
            ProfileScreen()
                .environmentObject(onlineViewModel)
        }
    }
    
    private func makeContent() -> some View {
        VStack(spacing: 24) {
            NavigationBar(text: "Heart Talk Online") {
                Image("profile")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundStyle(.darkWhite)
                    .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32, height: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32)
            } buttonAction: {
                isShowProfile.toggle()
            }
            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
            
            if onlineViewModel.isLoading {
                Spacer()
//                LoadingView(isBig: false)
                Spacer()
            } else {
                makeTools()
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
            }
            makeCenterView()
        }
        .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 8 : 24)
    }
    
    private func makeTools() -> some View {
        VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24) {
            OnlineSwitcher(selected: $selectedType)
            FillField(placeholder: "Search...", text: $searchText)
        }
    }
    
    private func makeCenterView() -> some View {
        VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32) {
            if !onlineViewModel.isLoading {
                switch selectedType {
                case .cards:
                    makeCardsFeed()
                case .accounts:
                    makeAccountsFeed()
                case .packs:
                    makePacksFeed()
                }
            }
            
            makeBackButton()
        }
        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 70 : 120)
    }
    
    private func makeCardsFeed() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(formatedCards()) { card in
                    OnlinePreviewCard(card: card, isAdded: onlineViewModel.favorites.contains(card)) {
                        if onlineViewModel.favorites.contains(card) {
                            onlineViewModel.removeFromFavorites(card)
                        } else {
                            onlineViewModel.addToFavorites(card)
                        }
                    }
                }
            }
        }
        .refreshable {
            onlineViewModel.fetchQuestions()
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
    }
    
    private func makePacksFeed() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24) {
                ForEach(formatedPacks()) { pack in
                    OnlinePack(OnlinePackProperties(color: Color(hex: pack.pack.color), header: pack.pack.name, description: pack.pack.text))
                }
            }
        }
        .refreshable {
            onlineViewModel.fetchPacks()
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
    }
    
    private func makeAccountsFeed() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24) {
                ForEach(formatedUsers()) { user in
                    OnlineAccountPreview(photoURL: user.photoURL, name: user.displayName) {
                        
                    }
                }
            }
        }
        .refreshable {
            onlineViewModel.fetchUsers()
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
    }
    
    private func formatedUsers() -> [FirebaseUser] {
        if searchText.isEmpty {
            return onlineViewModel.users
        } else {
            return onlineViewModel.users.filter({ $0.displayName.lowercased().contains(searchText.lowercased()) || $0.email.lowercased().contains(searchText.lowercased()) })
        }
    }
    
    private func formatedCards() -> [Card] {
        if searchText.isEmpty {
            return onlineViewModel.questions
        } else {
            return onlineViewModel.questions.filter({ $0.question.lowercased().contains(searchText.lowercased()) })
        }
    }
    
    private func formatedPacks() -> [FirebasePack] {
        if searchText.isEmpty {
            return onlineViewModel.packs
        } else {
            return onlineViewModel.packs.filter({ $0.pack.name.lowercased().contains(searchText.lowercased()) || $0.pack.description.lowercased().contains(searchText.lowercased()) || $0.tags.map({ $0.lowercased() }).contains(searchText.lowercased()) })
        }
    }
    
    private func makeBackButton() -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            dismiss()
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
