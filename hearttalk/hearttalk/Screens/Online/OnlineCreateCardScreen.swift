//
//  OnlineCreateCardScreen.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 30.01.2025.
//

import SwiftUI

struct OnlineCreateCardScreen: View {
    
    @EnvironmentObject var viewModel: OnlineViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var question: String = ""
    @State private var answer: String = ""
    @State private var isFlipCard: Bool = false
    
    @State private var isShowAlert: Bool = false
    @State private var isShowPackSelect: Bool = false
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .edgesIgnoringSafeArea(.bottom)
            .alert(isPresented: $isShowAlert) {
                Alert(title: Text(Localization.alert), message: Text(Localization.questionAlertMessage), dismissButton: .default(Text(Localization.confirm), action: {}))
            }
            .actionSheet(isPresented: $isShowPackSelect) {
                ActionSheet(
                    title: Text(Localization.packs),
                    buttons: makeActionSheetButtons()
                )
            }
    }
    
    private func makeContent() -> some View {
        VStack(spacing: 24) {
            SingleBackTopBar(text: Localization.newCard) {
                dismiss()
            }
            .padding(.vertical, 16)
            
            VStack(spacing: 40) {
                VStack(spacing: 16) {
                    CustomTextField(placeholder: Localization.questionPlaceholder, text: $question)
                    if isFlipCard {
                        CustomTextField(placeholder: Localization.answerPlaceholder, text: $answer)
                    }
                }
                QuestionToggle(text: Localization.flipCard, isOn: $isFlipCard)
                SettingsButton(text: viewModel.selectedSavingType?.name ?? Localization.notSet) {
                    viewModel.fetchMyContent {
                        isShowPackSelect.toggle()
                    }
                }
                Spacer()
                makeCreateButton()
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 70 : 120)
    }
    
    private func makeCreateButton() -> some View {
        Button {
            if checkText() {
                HapticManager.shared.triggerHapticFeedback(.light)
                SoundManager.shared.sound(.click1)
                createAction()
                dismiss()
            } else {
                isShowAlert.toggle()
            }
        } label: {
            Text(Localization.create)
                .font(.custom("Poppins-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32))
                .underline()
                .multilineTextAlignment(.center)
                .foregroundStyle(.darkWhite)
        }
    }
    
    private func checkText() -> Bool {
        question.count > 6 && viewModel.selectedSavingType != nil
    }
    
    private func createAction() {
        let card = Card(id: UUID().uuidString, question: question)
        card.isFlipCard = isFlipCard
        if isFlipCard {
            card.answer = answer
        }
        viewModel.createQuestion(card)
    }
    
    private func makeActionSheetButtons() -> [ActionSheet.Button]  {
        var buttons: [ActionSheet.Button] = []
        
        viewModel.myPacks.forEach { pack in
            let button = ActionSheet.Button.default(Text(pack.pack.name), action: {
                viewModel.selectedSavingType = pack.pack
            })
            buttons.append(button)
        }
                                                        
        let button = ActionSheet.Button.cancel(Text(Localization.cancel))
        buttons.append(button)
        
        return buttons
    }
    
}
