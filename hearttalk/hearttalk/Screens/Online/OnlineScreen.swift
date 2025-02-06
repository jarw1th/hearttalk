
import SwiftUI

struct OnlineScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @EnvironmentObject var onlineViewModel: OnlineViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var isShowSignScreen: Bool = false
    @State private var preview: OnlineSectionType?
    @State private var pack: FirebasePack?
    @State private var selectedNamePack: Pack?
    @State private var selectedDescPack: Pack?
    @State private var selectedUser: FirebaseUser?
    
    @State private var searchText: String = ""
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .onAppear {
                if onlineViewModel.isSignedIn {
                    onlineViewModel.fetchAll()
                }
            }
            .onChange(of: onlineViewModel.needToUpdate) { value in
                guard value else { return }
                if onlineViewModel.isSignedIn {
                    onlineViewModel.fetchAll()
                    onlineViewModel.needToUpdate = false
                }
            }
            .fullScreenCover(isPresented: $isShowSignScreen) {
                SignScreen()
                    .environmentObject(onlineViewModel)
            }
            .fullScreenCover(item: $pack) { value in
                OnlineQuestions(pack: value)
                    .environmentObject(onlineViewModel)
                    .environmentObject(viewModel)
            }
            .fullScreenCover(item: $selectedUser) {
                if onlineViewModel.isSignedIn {
                    onlineViewModel.fetchFavorites()
                }
            } content: { value in
                OnlineAccountScreen(user: value)
                    .environmentObject(onlineViewModel)
                    .environmentObject(viewModel)
            }
            .fullScreenCover(item: $preview) { value in
                OnlinePreviewScreen(type: value, pack: $pack, selectedUser: $selectedUser, selectedNamePack: $selectedNamePack, selectedDescPack: $selectedDescPack)
                    .environmentObject(onlineViewModel)
            }
            .fullScreenCover(item: $selectedNamePack) { pack in
                ChangeTextScreen(text: Binding(get: {
                    pack.name
                }, set: {
                    onlineViewModel.updatePackName($0, for: pack) {
                        onlineViewModel.fetchAll()
                    }
                }))
            }
            .fullScreenCover(item: $selectedDescPack) { pack in
                ChangeTextScreen(text: Binding(get: {
                    pack.text
                }, set: {
                    onlineViewModel.updatePackDescription($0, for: pack) {
                        onlineViewModel.fetchAll()
                    }
                }))
            }
    }
    
    @ViewBuilder
    private func makeContent() -> some View {
        VStack(spacing: 24) {
            TopBar(text: TabType.search.text)
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
            
            if onlineViewModel.isSignedIn {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 40) {
                        SearchBar(placeholder: Localization.onlineSearch, text: $searchText)
                            .padding(.horizontal, 20)
                        
                        if onlineViewModel.isLoading {
                            LoadingView(isLarge: false)
                        } else {
                            VStack(spacing: 24) {
                                makeSection(Localization.onlineContent) {
                                    makeMyFeed()
                                }
                                makeSection(Localization.onlineCards) {
                                    preview = .cards
                                } content: {
                                    makeCardsFeed()
                                }
                                makeSection(Localization.onlinePacks) {
                                    preview = .packs
                                } content: {
                                    makePacksFeed()
                                }
                                makeSection("Profiles") {
                                    preview = .profiles
                                } content: {
                                    makeAccountsFeed()
                                }
                            }
                        }
                    }
                    .padding(.bottom, 16)
                    .padding(.top, 1)
                }
                .refreshable {
                    if onlineViewModel.isSignedIn {
                        onlineViewModel.fetchAll()
                    }
                }
            } else {
                VStack {
                    Spacer()
                    LoginButton {
                        isShowSignScreen = true
                    }
                    .padding(60)
                    Spacer()
                }
            }
        }
    }
    
    @ViewBuilder
    private func makeMyFeed() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                OnlinePreviewPack(pack: onlineViewModel.favorites) {
                    self.pack = onlineViewModel.favorites
                }
                ForEach(formatedMyContent().indices, id: \.self) { index in
                    OnlinePreviewPack(pack: formatedMyContent()[index]) {
                        self.pack = formatedMyContent()[index]
                    }
                    .contextMenu {
                        if formatedMyContent()[index].user == onlineViewModel.myUser?.id {
                            Button(role: .destructive) {
                                HapticManager.shared.triggerHapticFeedback(.light)
                                SoundManager.shared.sound(.click1)
                                onlineViewModel.deletePack(formatedMyContent()[index].pack)
                            } label: {
                                Text(Localization.delete)
                            }
                            Button {
                                HapticManager.shared.triggerHapticFeedback(.light)
                                SoundManager.shared.sound(.click1)
                                selectedNamePack = formatedPacks()[index].pack
                            } label: {
                                Text(Localization.changeName)
                            }
                            Button {
                                HapticManager.shared.triggerHapticFeedback(.light)
                                SoundManager.shared.sound(.click1)
                                selectedDescPack = formatedPacks()[index].pack
                            } label: {
                                Text(Localization.changeDescription)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    private func makePacksFeed() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(formatedPacks().indices, id: \.self) { index in
                    OnlinePreviewPack(pack: formatedPacks()[index]) {
                        self.pack = formatedPacks()[index]
                    }
                    .contextMenu {
                        if formatedPacks()[index].user == onlineViewModel.myUser?.id {
                            Button(role: .destructive) {
                                HapticManager.shared.triggerHapticFeedback(.light)
                                SoundManager.shared.sound(.click1)
                                onlineViewModel.deletePack(formatedPacks()[index].pack)
                            } label: {
                                Text(Localization.delete)
                            }
                            Button {
                                HapticManager.shared.triggerHapticFeedback(.light)
                                SoundManager.shared.sound(.click1)
                                selectedNamePack = formatedPacks()[index].pack
                            } label: {
                                Text(Localization.changeName)
                            }
                            Button {
                                HapticManager.shared.triggerHapticFeedback(.light)
                                SoundManager.shared.sound(.click1)
                                selectedDescPack = formatedPacks()[index].pack
                            } label: {
                                Text(Localization.changeDescription)
                            }
                        }
                    }
                    .onAppear {
                        if index == formatedPacks().count - 1 {
                            onlineViewModel.fetchPacks()
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    private func makeCardsFeed() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(formatedCards().indices, id: \.self) { index in
                    OnlinePreviewCard(favorites: onlineViewModel.favorites, question: formatedCards()[index]) {
                        if onlineViewModel.favorites.pack.cards.contains(formatedCards()[index]) {
                            onlineViewModel.removeFromFavorites(formatedCards()[index])
                        } else {
                            onlineViewModel.addToFavorites(formatedCards()[index])
                        }
                    }
                    .onAppear {
                        if index == formatedCards().count - 1 {
                            onlineViewModel.fetchQuestions()
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    private func makeAccountsFeed() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(Array(stride(from: 0, to: formatedUsers().count, by: 2)), id: \.self) { index in
                    VStack(spacing: 8) {
                        OnlineProfilePreview(image: formatedUsers()[index].photoURL, name: formatedUsers()[index].displayName) {
                            self.selectedUser = formatedUsers()[index]
                        }
                        .onAppear {
                            if index == formatedUsers().count - 1 || index == formatedUsers().count - 2 {
                                onlineViewModel.fetchUsers()
                            }
                        }
                        if index + 1 < formatedUsers().count {
                            OnlineProfilePreview(image: formatedUsers()[index + 1].photoURL, name: formatedUsers()[index + 1].displayName) {
                                self.selectedUser = formatedUsers()[index + 1]
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    private func makeSection<Content: View>(_ text: String, action: (() -> Void)? = nil, content: () -> Content) -> some View {
        VStack(spacing: 16) {
            if let action {
                Button {
                    action()
                } label: {
                    HStack {
                        Text(text)
                            .font(.custom("Poppins-Regular", size: 16))
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.darkWhite)
                        Spacer()
                        Icon(name: "rightArrow")
                    }
                    .padding(.horizontal, 20)
                }
            } else {
                HStack {
                    Text(text)
                        .font(.custom("Poppins-Regular", size: 16))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.darkWhite)
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            content()
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
            return onlineViewModel.allPacks
        } else {
            return onlineViewModel.allPacks.filter({ $0.pack.name.lowercased().contains(searchText.lowercased()) || $0.pack.description.lowercased().contains(searchText.lowercased()) || $0.tags.map({ $0.lowercased() }).contains(searchText.lowercased()) })
        }
    }
    
    private func formatedMyContent() -> [FirebasePack] {
        if searchText.isEmpty {
            return onlineViewModel.myPacks.sorted(by: { $0.id > $1.id })
        } else {
            return onlineViewModel.myPacks.filter({ $0.pack.name.lowercased().contains(searchText.lowercased()) || $0.pack.description.lowercased().contains(searchText.lowercased()) || $0.tags.map({ $0.lowercased() }).contains(searchText.lowercased()) }).sorted(by: { $0.id > $1.id })
        }
    }
    
}
