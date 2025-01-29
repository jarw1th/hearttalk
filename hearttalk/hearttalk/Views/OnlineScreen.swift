
import SwiftUI

struct OnlineScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var onlineViewModel: OnlineViewModel = OnlineViewModel()
    
    @State private var needsToSign: Bool = true
    @State private var isShowSettings: Bool = false
    @State private var isShowSignScreen: Bool = false
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationView {
            makeContent()
                .background(.lightBlack)
        }
        .onAppear {
            if onlineViewModel.isSignedIn {
                onlineViewModel.fetchAll()
            } else if needsToSign {
                isShowSignScreen.toggle()
            } else {
                dismiss()
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
        .fullScreenCover(isPresented: $isShowSignScreen) {
            SignScreen(needsToSign: $needsToSign)
                .environmentObject(onlineViewModel)
        }
        .fullScreenCover(isPresented: $isShowSettings) {
            Settings()
                .environmentObject(onlineViewModel)
        }
    }
    
    @ViewBuilder
    private func makeContent() -> some View {
        VStack(spacing: 40) {
            HomeTopBar(text: "Online") {
                isShowSettings.toggle()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            
            SearchBar(placeholder: "Search...", text: $searchText)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    makeSection("Cards") {
                        makeCardsFeed()
                    }
                    makeSection("Packs") {
                        makePacksFeed()
                    }
                    makeSection("Accounts") {
                        makeAccountsFeed()
                    }
                    makeSection("My content", isCreatable: true) {
                        makeMyFeed()
                    }
                }
            }
            .refreshable {
                onlineViewModel.fetchAll()
            }
        }
    }
    
    @ViewBuilder
    private func makeMyFeed() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(formatedMyContent()) { pack in
                   
                }
            }
        }
    }
    
    @ViewBuilder
    private func makePacksFeed() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(formatedPacks()) { pack in
                    Text("\(pack.id)")
                }
            }
        }
    }
    
    @ViewBuilder
    private func makeCardsFeed() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(formatedCards()) { card in
                    Text("\(card.id)")
                }
            }
        }
    }
    
    @ViewBuilder
    private func makeAccountsFeed() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(formatedUsers()) { user in
                    Text("\(user.id)")
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
                        
                    } label: {
                        Icon(name: "add")
                    }
                }
            }
            .padding(.horizontal, 20)
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
            return onlineViewModel.packs
        } else {
            return onlineViewModel.packs.filter({ $0.pack.name.lowercased().contains(searchText.lowercased()) || $0.pack.description.lowercased().contains(searchText.lowercased()) || $0.tags.map({ $0.lowercased() }).contains(searchText.lowercased()) })
        }
    }
    
    private func formatedMyContent() -> [FirebasePack] {
        return []
    }
    
}
