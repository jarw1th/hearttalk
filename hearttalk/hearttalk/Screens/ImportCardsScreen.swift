//
//  ImportCardsScreen.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 31.01.2025.
//

import SwiftUI

struct ImportCardsScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var isCreateNewPack: Bool = false
    @State private var packName: String = ""
    @State private var packDescription: String = ""
    @State private var color: Color = Color(hex: "#9CAFB7")
    @State private var htFile: URL?
    @State private var qlFile: URL?
    @State private var apFile: URL?
    
    @State private var alertType: ImportAlertType? = nil
    @State private var isShowPackSelect: Bool = false
    @State private var importType: ImportType? = nil
    @State private var isShowFileImporter: Bool = false
    
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
            .fileImporter(isPresented: $isShowFileImporter, allowedContentTypes: [.plainText]) { result in
                switch importType {
                case .ht:
                    htFile = try? result.get()
                case .quizlet:
                    qlFile = try? result.get()
                case .anki:
                    apFile = try? result.get()
                case nil:
                    return
                }
            }
    }
    
    private func makeContent() -> some View {
        VStack(spacing: 24) {
            SingleBackTopBar(text: Localization.importCards) {
                dismiss()
            }
            .padding(.vertical, 16)
            
            VStack(spacing: 40) {
                VStack(spacing: 16) {
                    if (qlFile == nil && htFile == nil && apFile == nil) || htFile != nil {
                        ImportOption(text: "Heart Talk (.txt)", isImported: htFile != nil) {
                            importType = .ht
                            isShowFileImporter.toggle()
                        } closeTapAction: {
                            htFile = nil
                        } tipTapAction: {
                            alertType = .txt
                        }
                    }
                    if (qlFile == nil && htFile == nil && apFile == nil) || qlFile != nil {
                        ImportOption(text: "Quizlet (.txt, .csv)", isImported: qlFile != nil) {
                            importType = .quizlet
                            isShowFileImporter.toggle()
                        } closeTapAction: {
                            qlFile = nil
                        } tipTapAction: {
                            alertType = .quizlet
                        }
                    }
                    if (qlFile == nil && htFile == nil && apFile == nil) || apFile != nil {
                        ImportOption(text: "AnkiPro (.txt, .csv)", isImported: apFile != nil) {
                            importType = .anki
                            isShowFileImporter.toggle()
                        } closeTapAction: {
                            apFile = nil
                        } tipTapAction: {
                            alertType = .anki
                        }
                    }
                }
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
                alertType = .packName
            }
        } label: {
            Text(Localization.importText)
                .font(.custom("Poppins-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32))
                .underline()
                .multilineTextAlignment(.center)
                .foregroundStyle(.darkWhite)
        }
    }
    
    private func checkText() -> Bool {
        isCreateNewPack ? packName.count > 4 : viewModel.selectedSavingType != nil
    }
    
    private func createAction() {
        var pack: Pack? = viewModel.selectedSavingType
        if isCreateNewPack {
            pack = viewModel.createPack(name: packName, color: color.hex() ?? "", description: packDescription, cardQuestions: [])
        }
        guard let pack else { return }
        if let htFile {
            viewModel.importFrom(htFile, for: pack)
        } else if let qlFile {
            viewModel.importFromText(qlFile, for: pack)
        } else if let apFile {
            viewModel.importFromText(apFile, for: pack)
        }
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
