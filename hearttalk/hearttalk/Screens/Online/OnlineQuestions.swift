//
//  OnlineQuestions.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 01.02.2025.
//

import SwiftUI

struct OnlineQuestions: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @EnvironmentObject var onlineViewModel: OnlineViewModel
    @Environment(\.dismiss) var dismiss
    
    var pack: FirebasePack
    
    @State private var questionMode: QuestionMode = .cards
    @State private var isEdit: Bool = false
    
    @State private var isShowDecription: Bool = false
    @State private var isSaveCurrent: Bool = false
    @State private var isShowChangeText: Bool = false
    @State private var isShowChangeAnswer: Bool = false
    
    @State private var size: CGSize = .zero
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .edgesIgnoringSafeArea(.bottom)
            .onAppear {
                if pack == onlineViewModel.favorites {
                    onlineViewModel.fetchFavorites(pack.user)
                } else {
                    onlineViewModel.fetchCards(pack.user, for: pack)
                }
                onlineViewModel.cardIndex = 0
            }
            .onChange(of: onlineViewModel.needToUpdate) { value in
                guard value else { return }
                if pack == onlineViewModel.favorites {
                    onlineViewModel.fetchFavorites(pack.user)
                } else {
                    onlineViewModel.fetchCards(pack.user, for: pack)
                }
                onlineViewModel.cardIndex = 0
                onlineViewModel.needToUpdate = false
            }
            .alert(isPresented: $isShowDecription) {
                Alert(title: Text(Localization.description), message: Text(pack.pack.text), dismissButton: .default(Text(Localization.ok)))
            }
            .onChange(of: isSaveCurrent) { newValue in
                guard newValue else { return }
                let card = onlineViewModel.cards[onlineViewModel.cardIndex]
                viewModel.addCardToFavorites(card)
                isSaveCurrent = false
            }
            .fullScreenCover(isPresented: $isShowChangeText) {
                ChangeTextScreen(text: Binding(get: {
                    onlineViewModel.cards[onlineViewModel.cardIndex].question
                }, set: {
                    onlineViewModel.updateQuestion($0, for: onlineViewModel.cards[onlineViewModel.cardIndex], and: pack.pack) {
                        if pack == onlineViewModel.favorites {
                            onlineViewModel.fetchFavorites(pack.user)
                        } else {
                            onlineViewModel.fetchCards(pack.user, for: pack)
                        }
                    }
                }))
            }
            .fullScreenCover(isPresented: $isShowChangeAnswer) {
                ChangeTextScreen(text: Binding(get: {
                    onlineViewModel.cards[onlineViewModel.cardIndex].answer
                }, set: {
                    onlineViewModel.updateAnswer($0, for: onlineViewModel.cards[onlineViewModel.cardIndex], and: pack.pack) {
                        if pack == onlineViewModel.favorites {
                            onlineViewModel.fetchFavorites(pack.user)
                        } else {
                            onlineViewModel.fetchCards(pack.user, for: pack)
                        }
                    }
                }))
            }
    }
    
    @ViewBuilder
    private func makeContent() -> some View {
        VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32) {
            BackTopBar(text: pack.pack.name, isEdit: isEdit, isSelected: onlineViewModel.isSelected()) {
                if !onlineViewModel.isSelected() {
                    onlineViewModel.selectedCards = onlineViewModel.cards
                } else {
                    onlineViewModel.selectedCards = []
                }
            } deleteTapAction: {
                onlineViewModel.deleteQuestions(for: pack.pack)
            } optionButtons: {
                makeOptionsButtons()
            } closeTapAction: {
                if isEdit {
                    isEdit = false
                } else {
                    dismiss()
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
            
            if onlineViewModel.isLoading {
                Spacer()
                LoadingView(isLarge: false)
                Spacer()
            } else {
                if questionMode == .list {
                    makeList()
                } else {
                    makeCards()
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func makeCards() -> some View {
        ZStack(alignment: .bottom) {
            OnlineCardView(isSaveCurrent: $isSaveCurrent)
                .environmentObject(onlineViewModel)
        }
        .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 8 : 24)
        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 120)
    }
    
    @ViewBuilder
    private func makeList() -> some View {
        VStack {
            if onlineViewModel.cards.count == 0 {
                VStack {
                    Spacer()
                    Text(Localization.emptyPack)
                        .font(.custom("Poppins-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 32))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.darkWhite)
                        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 48 : 100)
                    Spacer()
                }
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack {
                        ForEach(Array(onlineViewModel.cards.enumerated()), id: \.element.id) { index, card in
                            CardsListItem(index: index, question: card.question, isSelected: isEdit ? onlineViewModel.selectedCards.contains(card) : true) {
                                if isEdit {
                                    if onlineViewModel.selectedCards.contains(card) {
                                        onlineViewModel.selectedCards.removeAll(where: { $0 == card })
                                    } else {
                                        onlineViewModel.selectedCards.append(card)
                                    }
                                } else {
                                    onlineViewModel.cardIndex = index
                                    questionMode.toggle()
                                }
                            }
                        }
                    }
                }
                .refreshable {
                    if pack == onlineViewModel.favorites {
                        onlineViewModel.fetchFavorites(pack.user)
                    } else {
                        onlineViewModel.fetchCards(pack.user, for: pack)
                    }
                    onlineViewModel.cardIndex = 0
                }
                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
            }
        }
    }
    
    @ViewBuilder
    private func makeOptionsButtons() -> some View {
        VStack {
            Button {
                HapticManager.shared.triggerHapticFeedback(.light)
                SoundManager.shared.sound(.click1)
                questionMode.toggle()
            } label: {
                Text(questionMode == .list ? Localization.cardsSection : Localization.list)
            }
            if !pack.pack.text.isEmpty {
                Button {
                    HapticManager.shared.triggerHapticFeedback(.light)
                    SoundManager.shared.sound(.click1)
                    isShowDecription.toggle()
                } label: {
                    Text(Localization.description)
                }
            }
            Button {
                HapticManager.shared.triggerHapticFeedback(.light)
                SoundManager.shared.sound(.click1)
                onlineViewModel.shuffle()
            } label: {
                Text(Localization.shuffle)
            }
            if questionMode == .list {
                if !onlineViewModel.cards.isEmpty && pack.user == onlineViewModel.myUser?.id {
                    Button(role: .destructive) {
                        HapticManager.shared.triggerHapticFeedback(.light)
                        SoundManager.shared.sound(.click1)
                        isEdit.toggle()
                    } label: {
                        Text(Localization.delete)
                    }
                }
            } else {
                if pack != onlineViewModel.favorites {
                    Button {
                        HapticManager.shared.triggerHapticFeedback(.light)
                        SoundManager.shared.sound(.click1)
                        viewModel.savePack(pack.pack)
                    } label: {
                        Text(Localization.savePack)
                    }
                }
                if onlineViewModel.cards.count != 0 && onlineViewModel.cards.count != onlineViewModel.cardIndex {
                    Button {
                        HapticManager.shared.triggerHapticFeedback(.light)
                        SoundManager.shared.sound(.click1)
                        onlineViewModel.addToFavorites(onlineViewModel.cards[onlineViewModel.cardIndex])
                    } label: {
                        Text(Localization.addToFav)
                    }
                    if pack.user == onlineViewModel.myUser?.id {
                        Button {
                            HapticManager.shared.triggerHapticFeedback(.light)
                            SoundManager.shared.sound(.click1)
                            isShowChangeText.toggle()
                        } label: {
                            Text(Localization.changeQ)
                        }
                        if viewModel.cards.count > viewModel.cardIndex,
                           viewModel.cards[viewModel.cardIndex].isFlipCard {
                            Button {
                                HapticManager.shared.triggerHapticFeedback(.light)
                                SoundManager.shared.sound(.click1)
                                isShowChangeAnswer.toggle()
                            } label: {
                                Text(Localization.changeA)
                            }
                        }
                        Button(role: .destructive) {
                            HapticManager.shared.triggerHapticFeedback(.light)
                            SoundManager.shared.sound(.click1)
                            if onlineViewModel.cards.count > onlineViewModel.cardIndex {
                                onlineViewModel.deleteQuestion(onlineViewModel.cards[onlineViewModel.cardIndex], for: pack.pack)
                            }
                        } label: {
                            Text(Localization.deleteCurrent)
                        }
                    }
                }
                if pack != onlineViewModel.favorites && pack.user == onlineViewModel.myUser?.id {
                    Button(role: .destructive) {
                        HapticManager.shared.triggerHapticFeedback(.light)
                        SoundManager.shared.sound(.click1)
                        onlineViewModel.deletePack(pack.pack)
                        dismiss()
                    } label: {
                        Text(Localization.deleteThisPack)
                    }
                }
            }
        }
    }
    
}
