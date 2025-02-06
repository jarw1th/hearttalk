//
//  OnlineAccountScreen.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 04.02.2025.
//

import SwiftUI

struct OnlineAccountScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @EnvironmentObject var onlineViewModel: OnlineViewModel
    @Environment(\.dismiss) var dismiss
    
    let user: FirebaseUser
    
    @State private var pack: FirebasePack?
    @State private var searchText: String = ""
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .onAppear {
                if onlineViewModel.isSignedIn && user.isShowMyContent {
                    onlineViewModel.fetchAll(for: user)
                }
            }
            .onChange(of: onlineViewModel.needToUpdate) { value in
                guard value else { return }
                if onlineViewModel.isSignedIn && user.isShowMyContent {
                    onlineViewModel.fetchAll(for: user)
                    onlineViewModel.needToUpdate = false
                }
            }
            .fullScreenCover(item: $pack) { value in
                OnlineQuestions(pack: value)
                    .environmentObject(viewModel)
                    .environmentObject(onlineViewModel)
            }
    }
    
    @ViewBuilder
    private func makeContent() -> some View {
        VStack(spacing: 24) {
            SingleBackTopBar(text: "Profile") {
                dismiss()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 40) {
                    OnlineAccountCredential(image: user.photoURL, name: user.displayName)
                        .padding(.horizontal, 20)
                    
                    OnlineAccountInfo(lastSeen: user.isShowStatus ? user.lastSeen : nil, email: user.isShowEmail ? user.email : nil)
                        .padding(.horizontal, 20)
                    
                    if onlineViewModel.isLoading {
                        LoadingView(isLarge: false)
                    } else if user.isShowMyContent {
                        VStack(spacing: 24) {
                            makeSection(Localization.onlinePacks) {
                                makePacksFeed()
                            }
                        }
                    }
                }
                .padding(.vertical, 16)
            }
            .refreshable {
                if onlineViewModel.isSignedIn && user.isShowMyContent {
                    onlineViewModel.fetchAll(for: user)
                }
            }
        }
    }
    
    @ViewBuilder
    private func makePacksFeed() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                OnlinePreviewPack(pack: onlineViewModel.favorites) {
                    self.pack = onlineViewModel.favorites
                }
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
                        }
                    }
                    .onAppear {
                        if index == formatedPacks().count - 1 {
                            onlineViewModel.fetchPacks(user.id)
                        }
                    }
                }
            }
            
                .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    private func makeSection<Content: View>(_ text: String, content: () -> Content) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text(text)
                    .font(.custom("Poppins-Regular", size: 16))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.darkWhite)
                Spacer()
            }
            .padding(.horizontal, 20)
            content()
        }
    }
    
    private func formatedPacks() -> [FirebasePack] {
        if searchText.isEmpty {
            return onlineViewModel.packs
        } else {
            return onlineViewModel.packs.filter({ $0.pack.name.lowercased().contains(searchText.lowercased()) || $0.pack.description.lowercased().contains(searchText.lowercased()) || $0.tags.map({ $0.lowercased() }).contains(searchText.lowercased()) })
        }
    }
    
}
