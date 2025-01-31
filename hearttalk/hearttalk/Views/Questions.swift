
import SwiftUI

struct Questions: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    
    var pack: Pack? = nil
    var card: Card? = nil
    
    @State private var questionMode: QuestionMode = .cards
    @State private var isEdit: Bool = false
    
    @State private var isShowDecription: Bool = false
    @State private var isShowNotes: Bool = false
    @State private var isShowLink: Bool = false
    @State private var isShowChangeText: Bool = false
    @State private var isShowChangeAnswer: Bool = false
    
    @State private var size: CGSize = .zero
    
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
            .fullScreenCover(isPresented: $isShowLink) {
                CreateLinkScreen(card: viewModel.cards[viewModel.cardIndex])
                    .environmentObject(viewModel)
            }
            .fullScreenCover(isPresented: $isShowChangeText) {
                ChangeTextScreen(text: Binding(get: {
                    viewModel.cards[viewModel.cardIndex].question
                }, set: {
                    let c = Card(id: viewModel.cards[viewModel.cardIndex].id, question: $0)
                    if viewModel.cards[viewModel.cardIndex].isFlipCard {
                        c.answer = viewModel.cards[viewModel.cardIndex].answer
                    }
                    viewModel.updateCard(c)
                }))
            }
            .fullScreenCover(isPresented: $isShowChangeAnswer) {
                ChangeTextScreen(text: Binding(get: {
                    viewModel.cards[viewModel.cardIndex].answer
                }, set: {
                    let c = Card(id: viewModel.cards[viewModel.cardIndex].id, question: viewModel.cards[viewModel.cardIndex].question)
                    c.answer = $0
                    viewModel.updateCard(c)
                }))
            }
            .alert(isPresented: $isShowDecription) {
                Alert(title: Text(Localization.description), message: Text(pack?.text ?? Localization.empty), dismissButton: .default(Text(Localization.ok)))
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
                BackTopBar(text: pack?.name ?? "", isEdit: isEdit, isSelected: viewModel.isSelected()) {
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
                            Text(Localization.list)
                        }
                        if let pack,
                           !pack.text.isEmpty {
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
                            viewModel.shuffle()
                        } label: {
                            Text(Localization.shuffle)
                        }
                        if viewModel.cards.count != 0 {
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
                                if viewModel.cards.count > viewModel.cardIndex {
                                    viewModel.deleteCard(viewModel.cards[viewModel.cardIndex])
                                }
                            } label: {
                                Text(Localization.deleteCurrent)
                            }
                        }
                        if viewModel.favoriteType != pack {
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
                                Text(Localization.deleteThisPack)
                            }
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
                .background(Rectangle().fill(.lightBlack))
                
                ZStack(alignment: .bottom) {
                    CardView(isShowNotes: $isShowNotes, isShowLink: $isShowLink)
                        .environmentObject(viewModel)
                }
            }
            .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 8 : 24)
            .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 120)
        }
    }
    
    @ViewBuilder
    private func makeList() -> some View {
        VStack {
            if viewModel.cards.count == 0 {
                ZStack {
                    VStack {
                        BackTopBar(text: pack?.name ?? "", isEdit: isEdit, isSelected: viewModel.isSelected()) {
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
                                    Text(Localization.cardsSection)
                                }
                                if let pack,
                                   !pack.text.isEmpty {
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
                                    viewModel.shuffle()
                                } label: {
                                    Text(Localization.shuffle)
                                }
                                if !viewModel.cards.isEmpty {
                                    Button(role: .destructive) {
                                        HapticManager.shared.triggerHapticFeedback(.light)
                                        SoundManager.shared.sound(.click1)
                                        isEdit.toggle()
                                    } label: {
                                        Text(Localization.delete)
                                    }
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
                        Spacer()
                    }
                    
                    VStack {
                        Spacer()
                        Text(Localization.emptyPack)
                            .font(.custom("Poppins-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 32))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.darkWhite)
                            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 48 : 100)
                        Spacer()
                    }
                }
            } else {
                VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 32) {
                    BackTopBar(text: pack?.name ?? "", isEdit: isEdit, isSelected: viewModel.isSelected()) {
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
                                Text(Localization.cardsSection)
                            }
                            if let pack,
                               !pack.text.isEmpty {
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
                                viewModel.shuffle()
                            } label: {
                                Text(Localization.shuffle)
                            }
                            if !viewModel.cards.isEmpty {
                                Button(role: .destructive) {
                                    HapticManager.shared.triggerHapticFeedback(.light)
                                    SoundManager.shared.sound(.click1)
                                    isEdit.toggle()
                                } label: {
                                    Text(Localization.delete)
                                }
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
    
}
