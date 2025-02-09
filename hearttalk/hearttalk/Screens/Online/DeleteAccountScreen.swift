//
//  DeleteAccountScreen.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 07.02.2025.
//

import SwiftUI

struct DeleteAccountScreen: View {
    
    @EnvironmentObject var viewModel: OnlineViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var password: String = ""
    
    @State private var alertType: OnlineAlertType?
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .edgesIgnoringSafeArea(.bottom)
            .alert(item: $alertType) { type in
                Alert(title: Text(Localization.onlineAlert), message: Text(type.text), dismissButton: .default(Text(Localization.confirm), action: {}))
            }
    }
    
    private func makeContent() -> some View {
        VStack(spacing: 24) {
            SingleBackTopBar(text: Localization.profile) {
                dismiss()
            }
            .padding(.vertical, 16)
            
            VStack(spacing: 40) {
                PasswordTextField(placeholder: Localization.onlinePassword, text: $password)
                Spacer()
                makeDeleteButton()
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 70 : 120)
    }
    
    private func makeDeleteButton() -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            if checkPassword() {
                resetAction()
            } else {
                alertType = .password
            }
        } label: {
            Text(Localization.delete)
                .font(.custom("Poppins-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32))
                .underline()
                .multilineTextAlignment(.center)
                .foregroundStyle(.darkWhite)
        }
    }
    
    private func checkPassword() -> Bool {
        if password.count <= 8 {
            return false
        }
        
        let regex = "^(?=.*[0-9])(?=.*[!@#$%^&*(),.?\":{}|<>]).+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: password)
    }
    
    private func resetAction() {
        viewModel.deleteAccount(password: password) { succuss in
            if succuss {
                dismiss()
            } else if let user = viewModel.myUser {
                alertType = .wrongPassword(user.email)
            }
        }
    }
    
}
