//
//  OnlineCreatePackScreen.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 30.01.2025.
//

import SwiftUI

struct OnlineCreatePackScreen: View {
    
    @EnvironmentObject var viewModel: OnlineViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var tags: [String] = []
    @State private var color: Color = Color(hex: "#9CAFB7")
    
    @State private var isShowAlert: Bool = false
    
    private let colors: [Color] = [Color(hex: "#9CAFB7"), Color(hex: "#ce796b"), Color(hex: "#e6b89c"), Color(hex: "#ead2ac"), Color(hex: "#8d8d92"), Color(hex: "#4281a4"), Color(hex: "#6b9080"), Color(hex: "#f6ca83"), Color(hex: "#63474d"), Color(hex: "#c57b57")]
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .edgesIgnoringSafeArea(.bottom)
            .alert(isPresented: $isShowAlert) {
                Alert(title: Text(Localization.alert), message: Text("Name should be at least 4 characters long."), dismissButton: .default(Text(Localization.confirm), action: {}))
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
                    CustomTextField(placeholder: "Name", text: $name)
                    CustomTextField(placeholder: "Description", text: $description)
                    TagsTextField(placeholder: "funny", tags: $tags)
                }
                ColorPicker(colors: colors, color: $color)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
        name.count > 4
    }
    
    private func createAction() {
        let pack = Pack()
        pack.id = UUID().uuidString
        pack.name = name
        pack.color = color.hex() ?? ""
        pack.text = description
        pack.creator = "me"
        pack.isCustom = true
        viewModel.createPack(pack, tags: tags)
    }
    
}
