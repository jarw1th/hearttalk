//
//  GenerateCardsScreen.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 31.01.2025.
//

import SwiftUI

struct GenerateCardsScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var isCreateNewPack: Bool = false
    @State private var packName: String = ""
    @State private var packDescription: String = ""
    @State private var color: Color = Color(hex: "#9CAFB7")
    @State private var isSingleCard: Bool = false
    @State private var cardNumber: String = ""
    @State private var prompt: String = ""
    
    @State private var alertType: GenerateAlertType? = nil
    @State private var isShowPackSelect: Bool = false
    @State private var isShowHeartTalkFiles: Bool = false
    
    private let colors: [Color] = [Color(hex: "#9CAFB7"), Color(hex: "#ce796b"), Color(hex: "#e6b89c"), Color(hex: "#ead2ac"), Color(hex: "#8d8d92"), Color(hex: "#4281a4"), Color(hex: "#6b9080"), Color(hex: "#f6ca83"), Color(hex: "#63474d"), Color(hex: "#c57b57")]
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .edgesIgnoringSafeArea(.bottom)
            .alert(item: $alertType) { type in
                Alert(title: Text(Localization.alert), message: Text(type.text), dismissButton: .default(Text(Localization.confirm), action: {}))
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
                CustomTextField(placeholder: Localization.promptPlaceholder, text: $prompt)
                QuestionToggle(text: Localization.createNewPack, isOn: $isCreateNewPack)
                if isCreateNewPack {
                    VStack(spacing: 16) {
                        CustomTextField(placeholder: Localization.packName, text: $packName)
                        CustomTextField(placeholder: Localization.packDescription, text: $packDescription)
                    }
                    ColorPicker(colors: colors, color: $color)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    SettingsButton(text: viewModel.selectedSavingType?.name ?? Localization.notSet) {
                        isShowPackSelect.toggle()
                    }
                }
                QuestionToggle(text: Localization.createOneCard, isOn: $isSingleCard)
                if !isSingleCard {
                    CustomTextField(placeholder: Localization.numberPlaceholder, type: .numeric, text: $cardNumber)
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
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            guard checkPrompt() else {
                alertType = .propmt
                return
            }
            guard checkText() else {
                alertType = .packName
                return
            }
            createAction()
        } label: {
            Text(Localization.generate)
                .font(.custom("Poppins-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32))
                .underline()
                .multilineTextAlignment(.center)
                .foregroundStyle(.darkWhite)
        }
    }
    
    private func checkText() -> Bool {
        isCreateNewPack ? packName.count > 4 : true
    }
    
    private func checkPrompt() -> Bool {
        prompt.count > 4
    }
    
    private func createAction() {
        var pack: Pack? = viewModel.selectedSavingType
        if isCreateNewPack {
            pack = viewModel.createPack(name: packName, color: color.hex() ?? "", description: packDescription, cardQuestions: [])
        }
        guard let pack else { return }
        viewModel.generate(from: prompt, using: pack, with: isSingleCard ? 1 : Int(cardNumber) ?? 1)
    }
    
    private func makeActionSheetButtons() -> [ActionSheet.Button]  {
        var buttons: [ActionSheet.Button] = []
        
        viewModel.myPacks.forEach { pack in
            let button = ActionSheet.Button.default(Text(pack.name), action: {
                viewModel.selectedSavingType = pack
            })
            buttons.append(button)
        }
                                                        
        let button = ActionSheet.Button.cancel(Text(Localization.cancel))
        buttons.append(button)
        
        return buttons
    }
    
}
