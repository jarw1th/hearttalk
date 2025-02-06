//
//  OnlineCardsScreen.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 05.02.2025.
//

import SwiftUI

struct OnlinePreviewScreen: View {
    
    @EnvironmentObject var onlineViewModel: OnlineViewModel
    @Environment(\.dismiss) var dismiss
    
    let type: OnlineSectionType
    
    @Binding var pack: FirebasePack?
    @Binding var selectedUser: FirebaseUser?
    @Binding var selectedNamePack: Pack?
    @Binding var selectedDescPack: Pack?
    
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
    }
    
    @ViewBuilder
    private func makeContent() -> some View {
        VStack(spacing: 24) {
            SingleBackTopBar(text: type.title) {
                dismiss()
            }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 40) {
                    SearchBar(placeholder: Localization.onlineSearch, text: $searchText)
                        .padding(.horizontal, 20)
                    
                    if onlineViewModel.isLoading {
                        LoadingView(isLarge: false)
                    } else {
                        switch type {
                        case .cards:
                            makeCardsFeed()
                        case .packs:
                            makePacksFeed()
                        case .profiles:
                            makeAccountsFeed()
                        }
                    }
                }
                .padding(.vertical, 16)
            }
            .refreshable {
                if onlineViewModel.isSignedIn {
                    onlineViewModel.fetchAll()
                }
            }
        }
    }
    
    @ViewBuilder
    private func makePacksFeed() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                ForEach(formatedPacks().indices, id: \.self) { index in
                    OnlinePreviewPack(pack: formatedPacks()[index], maxWidth: .infinity) {
                        dismiss()
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
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(Array(stride(from: 0, to: formatedCards().count, by: 2)), id: \.self) { index in
                    HStack(alignment: .top, spacing: 16) {
                        OnlinePreviewCard(favorites: onlineViewModel.favorites, question: formatedCards()[index], height: 200, maxWidth: .infinity) {
                            if onlineViewModel.favorites.pack.cards.contains(formatedCards()[index]) {
                                onlineViewModel.removeFromFavorites(formatedCards()[index])
                            } else {
                                onlineViewModel.addToFavorites(formatedCards()[index])
                            }
                        }
                        .onAppear {
                            if index == formatedCards().count - 1 || index == formatedCards().count - 2 {
                                onlineViewModel.fetchQuestions()
                            }
                        }
                        if index + 1 < formatedCards().count {
                            OnlinePreviewCard(favorites: onlineViewModel.favorites, question: formatedCards()[index + 1], height: 200, maxWidth: .infinity) {
                                if onlineViewModel.favorites.pack.cards.contains(formatedCards()[index + 1]) {
                                    onlineViewModel.removeFromFavorites(formatedCards()[index + 1])
                                } else {
                                    onlineViewModel.addToFavorites(formatedCards()[index + 1])
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    private func makeAccountsFeed() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                ForEach(formatedUsers().indices, id: \.self) { index in
                    OnlineProfilePreview(image: formatedUsers()[index].photoURL, name: formatedUsers()[index].displayName, maxWidth: .infinity) {
                        dismiss()
                        self.selectedUser = formatedUsers()[index]
                    }
                    .onAppear {
                        if index == formatedUsers().count - 1 {
                            onlineViewModel.fetchUsers()
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
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
    
}
