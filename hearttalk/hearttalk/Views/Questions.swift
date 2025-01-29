
import SwiftUI

struct Questions: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    
    var pack: Pack? = nil
    var card: Card? = nil
    
    @State private var questionMode: QuestionMode = .cards
    @State private var isEdit: Bool = false
    
    @State private var isShowNotes: Bool = false
    @State private var isShowChangeText: Bool = false
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .edgesIgnoringSafeArea(.bottom)
            .onAppear {
                if let card = card {
                    let pack = card.parentPack.first
                    viewModel.fetchCards(forPackId: pack?.id ?? "")
                    viewModel.cardIndex = viewModel.cards.firstIndex(of: card) ?? 0
                } else {
                    viewModel.fetchCards(forPackId: pack?.id ?? "")
                    viewModel.cardIndex = 0
                }
            }
            .fullScreenCover(isPresented: $isShowNotes) {
                NotesScreen(card: viewModel.cards[viewModel.cardIndex])
                    .environmentObject(viewModel)
            }
    }
    
    @ViewBuilder
    private func makeContent() -> some View {
        VStack {
            if questionMode == .list {
                makeList()
            } else {
                makeCards()
            }
        }
    }
    
    @ViewBuilder
    private func makeCards() -> some View {
        ZStack {
            VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 40 : 32) {
                BackTopBar(text: pack?.name ?? "Pack", isEdit: isEdit, isSelected: viewModel.isSelected()) {
                    if !viewModel.isSelected() {
                        viewModel.selectedCards = viewModel.cards
                    } else {
                        viewModel.selectedCards = []
                    }
                } deleteTapAction: {
                    viewModel.deleteCards()
                } optionButtons: {
                    VStack {
                        Button {
                            HapticManager.shared.triggerHapticFeedback(.light)
                            SoundManager.shared.sound(.click1)
                            questionMode = .list
                        } label: {
                            Text("List")
                        }
                        Button {
                            HapticManager.shared.triggerHapticFeedback(.light)
                            SoundManager.shared.sound(.click1)
                            viewModel.shuffle()
                        } label: {
                            Text("Shuffle")
                        }
                        Button(role: .destructive) {
                            HapticManager.shared.triggerHapticFeedback(.light)
                            SoundManager.shared.sound(.click1)
                            if let pack {
                                dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                                    viewModel.deletePack(pack)
                                }
                            }
                        } label: {
                            Text("Delete this pack")
                        }
                        Button(role: .destructive) {
                            HapticManager.shared.triggerHapticFeedback(.light)
                            SoundManager.shared.sound(.click1)
                            if viewModel.cards.count > viewModel.cardIndex {
                                viewModel.deleteCard(viewModel.cards[viewModel.cardIndex])
                            }
                        } label: {
                            Text("Delete current card")
                        }
                    }
                } closeTapAction: {
                    if isEdit {
                        isEdit = false
                    } else {
                        dismiss()
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
                
                ZStack(alignment: .bottom) {
                    CardView(isShowNotes: $isShowNotes)
                        .environmentObject(viewModel)
                    makeDescriptionButton()
                }
            }
            .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 8 : 24)
            .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 70 : 120)
        }
    }
    
    @ViewBuilder
    private func makeList() -> some View {
        VStack {
            if viewModel.cards.count == 0 {
                ZStack {
                    BackTopBar(text: pack?.name ?? "Pack", isEdit: isEdit, isSelected: viewModel.isSelected()) {
                        if !viewModel.isSelected() {
                            viewModel.selectedCards = viewModel.cards
                        } else {
                            viewModel.selectedCards = []
                        }
                    } deleteTapAction: {
                        viewModel.deleteCards()
                    } optionButtons: {
                        VStack {
                            Button {
                                HapticManager.shared.triggerHapticFeedback(.light)
                                SoundManager.shared.sound(.click1)
                                questionMode = .cards
                            } label: {
                                Text("Cards")
                            }
                            Button {
                                HapticManager.shared.triggerHapticFeedback(.light)
                                SoundManager.shared.sound(.click1)
                                isShowChangeText.toggle()
                            } label: {
                                Text("Change question")
                            }
                            Button {
                                HapticManager.shared.triggerHapticFeedback(.light)
                                SoundManager.shared.sound(.click1)
                                viewModel.shuffle()
                            } label: {
                                Text("Shuffle")
                            }
                            Button(role: .destructive) {
                                HapticManager.shared.triggerHapticFeedback(.light)
                                SoundManager.shared.sound(.click1)
                                isEdit.toggle()
                            } label: {
                                Text("Delete")
                            }
                        }
                    } closeTapAction: {
                        if isEdit {
                            isEdit = false
                        } else {
                            dismiss()
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
                    
                    VStack {
                        Spacer()
                        Text("Empty.")
                            .font(.custom("PlayfairDisplay-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 32))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.darkWhite)
                            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 48 : 100)
                        Spacer()
                    }
                }
            } else {
                VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32) {
                    BackTopBar(text: pack?.name ?? "Pack", isEdit: isEdit, isSelected: viewModel.isSelected()) {
                        if !viewModel.isSelected() {
                            viewModel.selectedCards = viewModel.cards
                        } else {
                            viewModel.selectedCards = []
                        }
                    } deleteTapAction: {
                        viewModel.deleteCards()
                    } optionButtons: {
                        VStack {
                            Button {
                                HapticManager.shared.triggerHapticFeedback(.light)
                                SoundManager.shared.sound(.click1)
                                questionMode = .cards
                            } label: {
                                Text("Cards")
                            }
                            Button {
                                HapticManager.shared.triggerHapticFeedback(.light)
                                SoundManager.shared.sound(.click1)
                                isShowChangeText.toggle()
                            } label: {
                                Text("Change question")
                            }
                            Button {
                                HapticManager.shared.triggerHapticFeedback(.light)
                                SoundManager.shared.sound(.click1)
                                viewModel.shuffle()
                            } label: {
                                Text("Shuffle")
                            }
                            Button(role: .destructive) {
                                HapticManager.shared.triggerHapticFeedback(.light)
                                SoundManager.shared.sound(.click1)
                                isEdit.toggle()
                            } label: {
                                Text("Delete")
                            }
                        }
                    } closeTapAction: {
                        if isEdit {
                            isEdit = false
                        } else {
                            dismiss()
                        }
                    }
                    .padding(.vertical, 16)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack {
                            ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, card in
                                CardsListItem(index: index, question: card.question, isSelected: isEdit ? viewModel.selectedCards.contains(card) : true) {
                                    if isEdit {
                                        if viewModel.selectedCards.contains(card) {
                                            viewModel.selectedCards.removeAll(where: { $0 == card })
                                        } else {
                                            viewModel.selectedCards.append(card)
                                        }
                                    } else {
                                        viewModel.cardIndex = index
                                        questionMode.toggle()
                                    }
                                }
                            }
                        }
                        
                    }
                }
                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
            }
        }
    }
    
    @ViewBuilder
    private func makeDescriptionButton() -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
        } label: {
            Icon(name: "upArrow")
        }
    }
    
}
