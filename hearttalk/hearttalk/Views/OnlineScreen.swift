
import SwiftUI

struct OnlineScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @EnvironmentObject var onlineViewModel: OnlineViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var isShowCreateCard: Bool = false
    @State private var isShowCreatePack: Bool = false
    @State private var isShowSignScreen: Bool = false
    @State private var searchText: String = ""
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .onAppear {
                if onlineViewModel.isSignedIn {
                    onlineViewModel.fetchAll()
                }
            }
            .onChange(of: onlineViewModel.isSignedIn) { newValue in
                if !newValue {
                    isShowSignScreen.toggle()
                }
            }
            .fullScreenCover(isPresented: $isShowCreateCard) {
                OnlineCreateCardScreen()
                    .environmentObject(onlineViewModel)
            }
            .fullScreenCover(isPresented: $isShowCreatePack) {
                OnlineCreatePackScreen()
                    .environmentObject(onlineViewModel)
            }
    }
    
    @ViewBuilder
    private func makeContent() -> some View {
        if onlineViewModel.isSignedIn {
            VStack(spacing: 40) {
                SearchBar(placeholder: Localization.onlineSearch, text: $searchText)
                    .padding(.horizontal, 20)
                
                VStack(spacing: 24) {
                    makeSection(Localization.onlineContent, isCreatable: true) {
                        makeMyFeed()
                    }
                    makeSection(Localization.onlineCards) {
                        makeCardsFeed()
                    }
                    makeSection(Localization.onlinePacks) {
                        makePacksFeed()
                    }
                    makeSection(Localization.onlineAccounts) {
                        makeAccountsFeed()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func makeMyFeed() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                PackView(color: "D44A13", name: Localization.onlineFavorites, numberOfCards: onlineViewModel.favorites.count)
                ForEach(formatedMyContent()) { pack in
                    OnlinePreviewPack(color: pack.pack.color, name: pack.pack.name, tags: pack.tags) {
                        
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func makePacksFeed() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(formatedPacks()) { pack in
                    OnlinePreviewPack(color: pack.pack.color, name: pack.pack.name, tags: pack.tags) {
                        
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func makeCardsFeed() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(formatedCards()) { card in
                    OnlinePreviewCard(isLiked: onlineViewModel.favorites.contains(card), question: card.question) {
                        
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func makeAccountsFeed() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(Array(stride(from: 0, to: formatedUsers().count, by: 2)), id: \.self) { index in
                    VStack(spacing: 8) {
                        OnlineProfilePreview(image: formatedUsers()[index].photoURL, name: formatedUsers()[index].displayName) {
                            
                        }
                        if index + 1 < formatedUsers().count {
                            OnlineProfilePreview(image: formatedUsers()[index + 1].photoURL, name: formatedUsers()[index + 1].displayName) {
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func makeSection<Content: View>(_ text: String, isCreatable: Bool = false, content: () -> Content) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text(text)
                    .font(.custom("Poppins-Regular", size: 16))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.darkWhite)
                Spacer()
                if isCreatable {
                    Menu {
                        Button(Localization.addCard) {
                            isShowCreateCard.toggle()
                        }
                        Button(Localization.addPack) {
                            isShowCreatePack.toggle()
                        }
                    } label: {
                        Icon(name: "add")
                    }
                }
            }
            .padding(.horizontal, 20)
            content()
                .padding(.leading, 20)
        }
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
    
    private func formatedMyContent() -> [FirebasePack] {
        if searchText.isEmpty {
            return onlineViewModel.myPacks
        } else {
            return onlineViewModel.myPacks.filter({ $0.pack.name.lowercased().contains(searchText.lowercased()) || $0.pack.description.lowercased().contains(searchText.lowercased()) || $0.tags.map({ $0.lowercased() }).contains(searchText.lowercased()) })
        }
    }
    
}
