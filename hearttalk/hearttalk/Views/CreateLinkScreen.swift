//
//  CreateLinkScreen.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 30.01.2025.
//

import SwiftUI
import PhotosUI

struct CreateLinkScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    
    var card: Card
    
    @State private var link: String = ""
    
    @State private var isShowAlert: Bool = false
    @State private var isShowWeb: Bool = false
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .edgesIgnoringSafeArea(.bottom)
            .alert(isPresented: $isShowAlert) {
                Alert(title: Text(Localization.alert), message: Text("Wrong link."), dismissButton: .default(Text(Localization.confirm), action: {}))
            }
            .sheet(isPresented: $isShowWeb) {
                WebBrowser(link: $link)
            }
    }
    
    @ViewBuilder
    private func makeContent() -> some View {
        VStack(spacing: 40) {
            SingleBackTopBar(text: "Link attach") {
                dismiss()
            }
            .padding(.vertical, 16)
            
            VStack(spacing: 24) {
                makeSection("Write link") {
                    CustomTextField(placeholder: "https://www.hearttalk.com", text: $link)
                }
                Spacer()
                makeCreateButton()
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 70 : 120)
    }
    
    @ViewBuilder
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
            Text("Attach")
                .font(.custom("Poppins-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32))
                .underline()
                .multilineTextAlignment(.center)
                .foregroundStyle(.darkWhite)
        }
    }
    
    private func checkText() -> Bool {
        !link.isEmpty
    }
    
    private func createAction() {
        viewModel.addLink(link, for: card)
    }
    
    @ViewBuilder
    private func makeSection<Content: View>(_ text: String, content: () -> Content) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 0) {
                Text("\(text) or ")
                    .font(.custom("Poppins-Regular", size: 16))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.darkWhite)
                Button {
                    isShowWeb.toggle()
                } label: {
                    Text("search for it")
                        .font(.custom("Poppins-Regular", size: 16))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.blue)
                }
                Spacer()
            }
            content()
        }
    }
    
}
