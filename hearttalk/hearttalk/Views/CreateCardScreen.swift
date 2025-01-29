//
//  CreateCardScreen.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 29.01.2025.
//

import SwiftUI

struct CreateCardScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var question: String = ""
    @State private var answer: String = ""
    @State private var isFlipCard: Bool = false
    
    @State private var isShowAlert: Bool = false
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .edgesIgnoringSafeArea(.bottom)
            .alert(isPresented: $isShowAlert) {
                Alert(title: Text(Localization.alert), message: Text("Question should be at least 10 characters long."), dismissButton: .default(Text(Localization.confirm), action: {}))
            }
    }
    
    private func makeContent() -> some View {
        VStack(spacing: 40) {
            SingleBackTopBar(text: "New pack") {
                dismiss()
            }
            .padding(.vertical, 16)
            
            VStack(spacing: 40) {
                VStack(spacing: 16) {
                    CustomTextField(placeholder: "Question", text: $question)
                    if isFlipCard {
                        CustomTextField(placeholder: "Answer", text: $answer)
                    }
                }
                QuestionToggle(text: "Flip card?", isOn: $isFlipCard)
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
        question.count > 10
    }
    
    private func createAction() {
        viewModel.createCard(question: question, answer: answer, isFlipCard: isFlipCard)
    }
    
}
